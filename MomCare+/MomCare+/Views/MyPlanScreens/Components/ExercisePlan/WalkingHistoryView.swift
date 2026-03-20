import SwiftUI
import Charts

struct WalkingHistoryView: View {

    // MARK: Lifecycle

    init(stepsGoal: Int) {
        self.stepsGoal = stepsGoal
    }

    // MARK: Internal

    let stepsGoal: Int

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    CompactCalendarView(
                        selectedDate: $selectedDate,
                        isExpanded: $isCalendarExpanded
                    )
                    .padding(.bottom, 8)

                    VStack(spacing: 16) {
                        selectedDayCard
                            .padding(.horizontal, 20)

                        chartSection
                            .padding(.horizontal, 20)

                        statsGrid
                            .padding(.horizontal, 20)

                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Walking History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
            }
            .onChange(of: selectedDate) {
                Task {
                    selectedDateSteps = await contentServiceHandler.fetchStepCount(for: selectedDate)
                    rangePoints = await contentServiceHandler.fetchWeeklyStepsProgress(from: selectedDate)
                }
            }
            .task {
                selectedDateSteps = await contentServiceHandler.fetchStepCount(for: selectedDate)
                rangePoints = await contentServiceHandler.fetchWeeklyStepsProgress(from: selectedDate)
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedDate: Date = .init()
    @State private var selectedDateSteps: Int = 0
    @State private var rangePoints: [StepDataPoint] = []
    @State private var isCalendarExpanded = false
    @State private var selectedBar: StepDataPoint?

    private var chartTitle: String = "This Week"

    private var chartSubtitle: String = "Daily step count"

    private var xAxisValues: [String] {
        return rangePoints.map { barLabel($0) }
    }

    private var average: Int {
        guard !rangePoints.isEmpty else { return 0 }
        return rangePoints.reduce(0) { $0 + $1.steps } / rangePoints.count
    }

    private var maximum: Int { rangePoints.map(\.steps).max() ?? 0 }

    private var totalForRange: Int { rangePoints.reduce(0) { $0 + $1.steps } }

    private var goalMetCount: Int {
        rangePoints.filter { $0.steps >= stepsGoal }.count
    }

    private var selectedDayCard: some View {
        let progress = min(Double(selectedDateSteps) / Double(max(stepsGoal, 1)), 1.0)
        let isToday = Calendar.current.isDateInToday(selectedDate)
        let metGoal = selectedDateSteps >= stepsGoal

        return HStack(spacing: 20) {
            // Ring
            ZStack {
                Circle()
                    .stroke(Color(hex: "4A8A62").opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color(hex: "4A8A62"),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? nil : .easeInOut, value: progress)

                VStack(spacing: 1) {
                    Text("\(Int(progress * 100))%")
                        .font(.body.weight(.bold))
                        .foregroundColor(Color(hex: "4A8A62"))
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: progress)
                }
            }
            .frame(width: 72, height: 72)

            // Numbers
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(selectedDateSteps.formatted())
                        .font(.largeTitle.weight(.heavy))
                        .foregroundColor(.primary)
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .easeInOut, value: selectedDateSteps)

                    Text("steps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 2)
                }

                HStack(spacing: 6) {
                    Text(isToday ? "Today" : formattedDate(selectedDate))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    if metGoal {
                        Label("Goal met", systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Color(hex: "4A8A62"))
                            .labelStyle(.titleAndIcon)
                    }
                }

                // Mini goal progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "4A8A62").opacity(0.12))
                        Capsule()
                            .fill(Color(hex: "4A8A62"))
                            .frame(width: geo.size.width * progress)
                            .animation(reduceMotion ? nil : .easeInOut, value: progress)
                    }
                }
                .frame(height: 6)

                Text("Goal: \(stepsGoal.formatted()) steps")
                    .font(.caption2)
                    .foregroundStyle(Color(.tertiaryLabel))
            }

            Spacer()
        }
        .padding(18)
        .shadow(color: Color(hex: "4A8A62").opacity(0.08), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isToday ? "Today's steps" : "Steps on \(formattedDate(selectedDate))")
        .accessibilityValue(
            metGoal ? "\(selectedDateSteps.formatted()) steps, goal met" : "\(selectedDateSteps.formatted()) of \(stepsGoal.formatted()) steps, \(Int(progress * 100)) percent"
        )
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(chartTitle)
                        .font(.headline.weight(.semibold))
                    Text(chartSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if let bar = selectedBar {
                HStack {
                    Text(barCalloutDate(bar.date))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(bar.steps.formatted() + " steps")
                        .font(.caption.weight(.bold))
                        .foregroundColor(
                            bar.steps >= stepsGoal
                                ? Color(hex: "4A8A62")
                                : Color.CustomColors.mutedRaspberry
                        )
                }
                .padding(.horizontal, 4)
                .transition(unsafe .opacity.combined(with: .scale(scale: 0.95)))
            }

            Chart(rangePoints) { pt in
                BarMark(
                    x: .value("Day", barLabel(pt)),
                    y: .value("Steps", pt.steps),
                    width: .ratio(0.55)
                )
                .foregroundStyle(
                    pt.steps >= stepsGoal
                        ? Color(hex: "4A8A62")
                        : Color.CustomColors.mutedRaspberry.opacity(
                            selectedBar?.id == pt.id ? 1.0 : 0.75
                          )
                )
                .cornerRadius(6)
                .accessibilityLabel(barLabel(pt))
                .accessibilityValue(
                    "\(pt.steps.formatted()) steps\(pt.steps >= stepsGoal ? ", goal met" : "")\(selectedBar?.id == pt.id ? ", selected" : "")"
                )

                RuleMark(y: .value("Goal", stepsGoal))
                    .lineStyle(StrokeStyle(lineWidth: 1.2, dash: [5, 3]))
                    .foregroundStyle(Color(hex: "4A8A62").opacity(0.45))
                    .annotation(position: .trailing, alignment: .center) {
                        Text("Goal")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color(hex: "4A8A62").opacity(0.7))
                    }
            }
            .chartXAxis {
                AxisMarks(values: xAxisValues) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading,
                          values: .automatic(desiredCount: 4)) { val in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4, dash: [4]))
                        .foregroundStyle(Color(.systemGray4))
                    AxisValueLabel {
                        if let v = val.as(Int.self) {
                            Text(shortStepLabel(v))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartScrollableAxes([])
            .chartXVisibleDomain(length: rangePoints.count)
            .frame(height: 200)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: rangePoints.count)
            // Tap to select bar
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            if let label: String = proxy.value(atX: location.x - geo[proxy.plotFrame!].minX),
                               let match = rangePoints.first(where: { barLabel($0) == label }) {
                                withAnimation(reduceMotion ? nil : .easeInOut) {
                                    selectedBar = selectedBar?.id == match.id ? nil : match
                                }
                            }
                        }
                }
            }

        }
        .padding(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(
                icon: "chart.bar.fill",
                label: "Average",
                value: average.formatted(),
                unit: "steps/day",
                color: Color(hex: "4A7A9B")
            )
            statCard(
                icon: "arrow.up.circle.fill",
                label: "Best day",
                value: maximum.formatted(),
                unit: "steps",
                color: Color(hex: "4A8A62")
            )
            statCard(
                icon: "sum",
                label: "Total",
                value: totalForRange.formatted(),
                unit: "steps",
                color: Color.CustomColors.mutedRaspberry
            )
            statCard(
                icon: "target",
                label: "Goal met",
                value: "\(goalMetCount)",
                unit: "of \(rangePoints.count) days",
                color: Color(hex: "9B6B52")
            )
        }
    }

    private func statCard(icon: String, label: String, value: String, unit: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.callout.weight(.medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.primary)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? nil : .easeInOut, value: value)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(Color(.tertiaryLabel))
            }

            Spacer()
        }
        .padding(14)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    private func barLabel(_ pt: StepDataPoint) -> String {
        pt.shortLabel
    }

    private func barCalloutDate(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateStyle = .medium; fmt.timeStyle = .none
        return fmt.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter(); fmt.dateStyle = .medium; fmt.timeStyle = .none
        return fmt.string(from: date)
    }

    private func shortStepLabel(_ v: Int) -> String {
        v >= 1000 ? "\(v / 1000)k" : "\(v)"
    }
}
