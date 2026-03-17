import SwiftUI
import Charts

struct VitalDetailView: View {

    // MARK: Internal

    let kind: VitalKind
    let todayValue: Double
    let targetValue: Double

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                todayHeader
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.8), value: appeared)

                descriptionCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.8).delay(0.05),
                        value: appeared
                    )

                chartSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8).delay(0.10),
                        value: appeared
                    )

                if showCalendar {
                    calendarSection
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                insightCard
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8).delay(0.15),
                        value: appeared
                    )

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(.systemBackground))
        .navigationTitle(kind.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await reload()
            withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .onChange(of: selectedRange) { _, new in
            if new == .calendar {
                withAnimation { showCalendar = true }
            } else {
                withAnimation { showCalendar = false }
                Task { await reload() }
            }
        }
    }

    // MARK: Private

    @StateObject private var store: VitalHistoryStore = .init()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    @State private var selectedRange: VitalTimeRange = .week
    @State private var calendarRange: ClosedRange<Date>?
    @State private var showCalendar = false
    @State private var appeared = false

    @State private var selectedPoint: DailyDataPoint?

    private var chartHeight: CGFloat { 220 }

    private var visibleDomain: Int {
        min(store.points.count, 7)
    }

    private var barWidth: MarkDimension {
        selectedRange == .quarter ? .ratio(0.5) : .ratio(0.6)
    }

    private var xAxisValues: [String] {
        // Thin out labels for large ranges to avoid crowding
        let all = store.points.map(\.label)
        guard all.count > 14 else { return all }
        let step = all.count / 7
        return stride(from: 0, to: all.count, by: step).map { all[$0] }
    }

    private var todayHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(kind.color.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: kind.sfSymbol)
                    .font(.title2)
                    .foregroundColor(kind.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(formattedValue(todayValue))")
                        .font(.title.weight(.bold))
                        .contentTransition(.numericText())
                    Text(kind.unitLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5))
                        Capsule()
                            .fill(kind.color)
                            .frame(width: geo.size.width * min(todayValue / max(targetValue, 1), 1.0))
                    }
                }
                .frame(height: 5)
                .padding(.top, 2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Target")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text("\(formattedValue(targetValue))")
                    .font(.headline.weight(.semibold))
                Text(kind.unitLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            kind.color.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(kind.color.opacity(0.15), lineWidth: 1)
        )
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("About \(kind.rawValue)", systemImage: "info.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(kind.color)

            Text(kind.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Range picker (Segmented)
            Picker("Range", selection: $selectedRange) {
                ForEach(VitalTimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)

            // Chart or loading state
            ZStack {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: chartHeight)

                } else if store.points.isEmpty {
                    emptyChartPlaceholder

                } else {
                    chart
                }
            }
            .frame(height: chartHeight)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: store.isLoading)

            // Selected bar callout
            if let pt = selectedPoint {
                HStack {
                    Text(pt.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(formattedValue(pt.value)) \(kind.unitLabel)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(kind.color)
                }
                .padding(.horizontal, 4)
                .transition(unsafe .opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var chart: some View {
        Chart(store.points) { pt in
            BarMark(
                x: .value("Date", pt.label),
                y: .value(kind.unitLabel, appeared ? pt.value : 0),
                width: barWidth
            )
            .foregroundStyle(
                pt.id == selectedPoint?.id
                ? kind.color
                : kind.color.opacity(0.7)
            )
            .cornerRadius(5)
            .annotation(position: .overlay) {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedPoint = selectedPoint?.id == pt.id ? nil : pt
                        }
                    }
                    .contextMenu {
                        Text("\(pt.label): \(formattedValue(pt.value)) \(kind.unitLabel)")
                            .font(.caption)

                        Divider()

                        Button {
                            selectedPoint = pt
                        } label: {
                            Label("Select this day", systemImage: "hand.point.up.fill")
                        }

                        if targetValue > 0 {
                            let pct = Int((pt.value / targetValue) * 100)
                            Button(action: {}) {
                                Label("\(pct)% of daily target", systemImage: "target")
                            }
                            .disabled(true)
                        }

                        Button {
                            UIPasteboard.general.string = "\(formattedValue(pt.value)) \(kind.unitLabel)"
                        } label: {
                            Label("Copy value", systemImage: "doc.on.doc")
                        }
                    }
            }

            if targetValue > 0 {
                RuleMark(y: .value("Target", targetValue))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                    .foregroundStyle(kind.color.opacity(0.4))
                    .annotation(position: .trailing, alignment: .center) {
                        Text("Target")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(kind.color.opacity(0.6))
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: xAxisValues) { _ in
                AxisValueLabel()
                    .font(.system(size: 10))
                    .foregroundStyle(Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4, dash: [4]))
                    .foregroundStyle(Color(.systemGray4))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(formattedValue(v))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: visibleDomain)
        .animation(
            reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8),
            value: appeared
        )
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.3),
            value: store.points.count
        )
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundStyle(Color(.systemGray3))
            Text("No data for this period")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Log meals in Health to see your \(kind.rawValue.lowercased()) history here.")
                .font(.caption)
                .foregroundStyle(Color(.systemGray3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: chartHeight)
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Pick a date range")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if calendarRange != nil {
                    Button("Clear") {
                        calendarRange = nil
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            CalendarRangePicker(selectedRange: $calendarRange) { range in
                Task { await reloadCalendar(range: range) }
            }
            .frame(height: 340)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if let range = calendarRange {
                Text("\(formatDate(range.lowerBound)) – \(formatDate(range.upperBound))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var insightCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.subheadline)
                .foregroundColor(.orange)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tip")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)

                Text(kind.insight)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            Color.orange.opacity(0.06),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.orange.opacity(0.15), lineWidth: 1)
        )
    }

    private func reload() async {
        await store.load(kind: kind, range: selectedRange, calendarRange: calendarRange)
    }

    private func reloadCalendar(range: ClosedRange<Date>) async {
        await store.load(kind: kind, startDate: range.lowerBound, endDate: range.upperBound)
    }

    private func formattedValue(_ v: Double) -> String {
        if kind == .calories {
            return v.formatted(.number.precision(.fractionLength(0)))
            
        } else if kind == .sodium {
            return v >= 1000
                ? v.formatted(.number.precision(.fractionLength(1)))
                : v.formatted(.number.precision(.fractionLength(0)))
            
        } else {
            return v.formatted(.number.precision(.fractionLength(1)))
        }
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: date)
    }
}
