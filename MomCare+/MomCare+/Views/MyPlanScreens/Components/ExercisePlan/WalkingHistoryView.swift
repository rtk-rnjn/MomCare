import SwiftUI
import Charts

struct WalkingHistoryView: View {

    // MARK: Internal

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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Walking History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
            }
            .onChange(of: selectedDate) { _, new in
                Task {
                    await store.loadDay(date: new, handler: contentServiceHandler)
                    await store.loadRange(anchor: new, handler: contentServiceHandler)
                }
            }
            .task {
                store.goal = Int(contentServiceHandler.targetSteps)
                await store.loadDay(date: selectedDate, handler: contentServiceHandler)
                await store.loadRange(anchor: selectedDate, handler: contentServiceHandler)
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var contentServiceHandler: ContentServiceHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @StateObject private var store: WalkingHistoryStore = .init()

    @State private var selectedDate: Date = .init()
    @State private var isCalendarExpanded = false
    @State private var selectedBar: StepDataPoint?

    private var chartTitle: String = "This Week"

    private var chartSubtitle: String = "Daily step count"

    private var monthTitle: String {
        let fmt = DateFormatter(); fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: selectedDate)
    }

    private var xAxisValues: [String] {
        return store.rangePoints.map { barLabel($0) }
    }

    private var selectedDayCard: some View {
        let progress = min(Double(store.selectedDateSteps) / Double(max(store.goal, 1)), 1.0)
        let isToday = Calendar.current.isDateInToday(selectedDate)
        let metGoal = store.selectedDateSteps >= store.goal

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
                    .animation(reduceMotion ? nil : .spring(response: 0.7, dampingFraction: 0.8), value: progress)

                VStack(spacing: 1) {
                    Text("\(Int(progress * 100))%")
                        .font(.body.weight(.bold))
                        .foregroundColor(Color(hex: "4A8A62"))
                        .contentTransition(.numericText())
                }
            }
            .frame(width: 72, height: 72)

            // Numbers
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    if store.isLoadingDay {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Text(store.selectedDateSteps.formatted())
                            .font(.largeTitle.weight(.heavy))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                            .animation(reduceMotion ? nil : .spring(response: 0.5), value: store.selectedDateSteps)
                    }
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
                            .animation(reduceMotion ? nil : .spring(response: 0.7), value: progress)
                    }
                }
                .frame(height: 6)

                Text("Goal: \(store.goal.formatted()) steps")
                    .font(.caption2)
                    .foregroundStyle(Color(.tertiaryLabel))
            }

            Spacer()
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: "4A8A62").opacity(0.08), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isToday ? "Today's steps" : "Steps on \(formattedDate(selectedDate))")
        .accessibilityValue(
            metGoal
                ? "\(store.selectedDateSteps.formatted()) steps, goal met"
                : "\(store.selectedDateSteps.formatted()) of \(store.goal.formatted()) steps, \(Int(progress * 100)) percent"
        )
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header row
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

            // Selected bar callout
            if let bar = selectedBar {
                HStack {
                    Text(barCalloutDate(bar.date))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(bar.steps.formatted() + " steps")
                        .font(.caption.weight(.bold))
                        .foregroundColor(
                            bar.steps >= store.goal
                                ? Color(hex: "4A8A62")
                                : Color.CustomColors.mutedRaspberry
                        )
                }
                .padding(.horizontal, 4)
                .transition(unsafe .opacity.combined(with: .scale(scale: 0.95)))
            }

            // Chart
            if store.isLoadingRange {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay { ProgressView() }
            } else if store.rangePoints.isEmpty {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
            } else {
                Chart(store.rangePoints) { pt in
                    BarMark(
                        x: .value("Day", barLabel(pt)),
                        y: .value("Steps", pt.steps),
                        width: .ratio(0.55)
                    )
                    .foregroundStyle(
                        pt.steps >= store.goal
                            ? Color(hex: "4A8A62")
                            : Color.CustomColors.mutedRaspberry.opacity(
                                selectedBar?.id == pt.id ? 1.0 : 0.75
                              )
                    )
                    .cornerRadius(6)
                    .accessibilityLabel(barLabel(pt))
                    .accessibilityValue(
                        "\(pt.steps.formatted()) steps\(pt.steps >= store.goal ? ", goal met" : "")\(selectedBar?.id == pt.id ? ", selected" : "")"
                    )

                    // Goal rule line
                    RuleMark(y: .value("Goal", store.goal))
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
                .chartXVisibleDomain(length: store.rangePoints.count)
                .frame(height: 200)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: store.rangePoints.count)
                // Tap to select bar
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                if let label: String = proxy.value(atX: location.x - geo[proxy.plotFrame!].minX),
                                   let match = store.rangePoints.first(where: { barLabel($0) == label }) {
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.3)) {
                                        selectedBar = selectedBar?.id == match.id ? nil : match
                                    }
                                }
                            }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(
                icon: "chart.bar.fill",
                label: "Average",
                value: store.average.formatted(),
                unit: "steps/day",
                color: Color(hex: "4A7A9B")
            )
            statCard(
                icon: "arrow.up.circle.fill",
                label: "Best day",
                value: store.maximum.formatted(),
                unit: "steps",
                color: Color(hex: "4A8A62")
            )
            statCard(
                icon: "sum",
                label: "Total",
                value: store.totalForRange.formatted(),
                unit: "steps",
                color: Color.CustomColors.mutedRaspberry
            )
            statCard(
                icon: "target",
                label: "Goal met",
                value: "\(store.goalMetCount)",
                unit: "of \(store.rangePoints.count) days",
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
                    .contentTransition(.numericText())
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(Color(.tertiaryLabel))
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
