import SwiftUI

struct CompactCalendarView: View {

    // MARK: Internal

    @Binding var selectedDate: Date
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(spacing: 0) {
            header

            GeometryReader { geo in
                let width = geo.size.width

                ZStack(alignment: .top) {
                    WeekStripView(date: displayedDate, selectedDate: $selectedDate)
                        .offset(x: slideOffset)
                        .opacity(Double(1 - expandProgress))
                        .offset(y: -expandProgress * verticalOffsetAmount)
                        .gesture(dragGesture(width: width))

                    MonthGridView(
                        date: displayedDate,
                        selectedDate: $selectedDate,
                        showsOutOfMonthDays: showsOutOfMonthDays,
                        alwaysSixWeeks: alwaysSixWeeks,
                        cellHeight: cellHeight,
                        headerBottomPadding: monthHeaderBottomPadding
                    )
                    .offset(x: slideOffset)
                    .opacity(Double(expandProgress))
                    .offset(y: (1 - expandProgress) * verticalOffsetAmount)
                    .gesture(dragGesture(width: width))

                    if let incoming = incomingDate {
                        Group {
                            if isExpanded {
                                MonthGridView(
                                    date: incoming,
                                    selectedDate: $selectedDate,
                                    showsOutOfMonthDays: showsOutOfMonthDays,
                                    alwaysSixWeeks: alwaysSixWeeks,
                                    cellHeight: cellHeight,
                                    headerBottomPadding: monthHeaderBottomPadding
                                )
                                .gesture(dragGesture(width: width))

                            } else {
                                WeekStripView(date: incoming, selectedDate: $selectedDate)
                                    .gesture(dragGesture(width: width))

                            }
                        }
                        .offset(x: slideOffset + incomingDirection * width)
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .gesture(dragGesture(width: width))
            }
            .frame(height: currentHeight)
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .onAppear {
            displayedDate = selectedDate
            expandProgress = isExpanded ? 1 : 0
        }
        .onChange(of: isExpanded) { _, newValue in
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) {
                expandProgress = newValue ? 1 : 0
            }
        }
    }

    // MARK: Private

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var slideOffset: CGFloat = 0
    @State private var displayedDate: Date = .init()
    @State private var incomingDate: Date?
    @State private var incomingDirection: CGFloat = 0
    @State private var isDraggingHorizontal: Bool?

    @State private var expandProgress: CGFloat = 0

    private let calendar: Calendar = .current

    private let showsOutOfMonthDays: Bool = false
    private let alwaysSixWeeks: Bool = false

    private let cellHeight: CGFloat = 44
    private let monthHeaderHeight: CGFloat = 18
    private let monthHeaderBottomPadding: CGFloat = 8
    private let verticalOffsetAmount: CGFloat = 20

    private var calendarToggleAccessibilityLabel: String {
        let monthYear = displayedDate.formatted(.dateTime.month(.wide).year())
        return isExpanded ? "\(monthYear), expanded" : "\(monthYear), collapsed"
    }

    private var compactHeight: CGFloat {
        cellHeight + 8
    }

    private var expandedHeight: CGFloat {
        let rows = monthRowCount(for: displayedDate)
        let grid = CGFloat(rows) * cellHeight

        let headerRowAndPadding = monthHeaderHeight + monthHeaderBottomPadding + 12
        return headerRowAndPadding + grid
    }

    private var expandTravelDistance: CGFloat { 120 }

    private var currentHeight: CGFloat {
        compactHeight + (expandedHeight - compactHeight) * expandProgress
    }

    private var header: some View {
        HStack {
            Button {
                withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                    expandProgress = isExpanded ? 1 : 0
                }
            } label: {
                HStack(alignment: .center) {

                    GeometryReader { g in
                        let w = max(g.size.width, 1)

                        let raw = min(abs(slideOffset) / w, 1)
                        let t = raw * raw * (3 - 2 * raw)

                        let currentTitleDate = isExpanded ? displayedDate : startOfWeek(for: displayedDate)
                        let incomingTitleDate: Date? = incomingDate.map { isExpanded ? $0 : startOfWeek(for: $0) }

                        let dir: CGFloat = slideOffset < 0 ? -1 : 1

                        ZStack(alignment: .center) {
                            Text(currentTitleDate.formatted(.dateTime.month(.wide).year()))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .opacity(1 - t)
                                .scaleEffect(1 - 0.02 * t, anchor: .leading)
                                .offset(x: -8 * t * dir)

                            if let incomingTitleDate {
                                Text(incomingTitleDate.formatted(.dateTime.month(.wide).year()))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .opacity(t)
                                    .scaleEffect(0.98 + 0.02 * t, anchor: .leading)
                                    .offset(x: 8 * (1 - t) * dir)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .clipped()
                        .animation(.none, value: slideOffset)
                    }
                    .frame(height: monthHeaderHeight)

//                    Image(systemName: "chevron.down")
//                        .font(.caption2.weight(.semibold))
//                        .foregroundColor(.secondary)
//                        .rotationEffect(.degrees(expandProgress * -180))
//                        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8), value: expandProgress)
//                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(calendarToggleAccessibilityLabel)
            .accessibilityHint(isExpanded ? "Collapses the calendar view" : "Expands the calendar view")

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { handleDragChanged($0) }
            .onEnded { handleDragEnded($0, width: width) }
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        let h = value.translation.width
        let v = value.translation.height

        detectDragDirection(horizontal: h, vertical: v)

        if isDraggingHorizontal == true {
            handleHorizontalDrag(h)
        } else if isDraggingHorizontal == false {
            handleVerticalDrag(v)
        }
    }

    private func detectDragDirection(horizontal h: CGFloat, vertical v: CGFloat) {
        guard isDraggingHorizontal == nil else { return }

        if abs(h) > abs(v) + 5 {
            isDraggingHorizontal = true
        } else if abs(v) > abs(h) + 5 {
            isDraggingHorizontal = false
        }
    }

    private func handleHorizontalDrag(_ h: CGFloat) {
        let direction: CGFloat = h < 0 ? -1 : 1

        if incomingDate == nil {
            incomingDirection = -direction
            incomingDate = adjacentDate(direction: -direction)
        }

        slideOffset = h
    }

    private func handleVerticalDrag(_ v: CGFloat) {
        if !isExpanded {
            expandProgress = clamp(v / expandTravelDistance)
        } else {
            expandProgress = clamp(1 + v / expandTravelDistance)
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value, width: CGFloat) {
        let h = value.translation.width
        let velocityX = value.velocity.width
        let velocityY = value.velocity.height

        if isDraggingHorizontal == true {
            finishHorizontalDrag(h: h, velocityX: velocityX, width: width)
        } else if isDraggingHorizontal == false {
            finishVerticalDrag(velocityY: velocityY)
        } else {
            resetVerticalState()
            cancelSlide()
        }

        isDraggingHorizontal = nil
    }

    private func finishHorizontalDrag(h: CGFloat, velocityX: CGFloat, width: CGFloat) {
        let direction: CGFloat = h < 0 ? -1 : 1
        let shouldCommit = abs(h) > 30 || abs(velocityX) > 300

        if shouldCommit {
            commitSlide(direction: direction, width: width)
        } else {
            cancelSlide()
        }
    }

    private func finishVerticalDrag(velocityY: CGFloat) {
        let shouldExpand = !isExpanded && (expandProgress > 0.4 || velocityY > 400)
        let shouldCollapse = isExpanded && (expandProgress < 0.6 || velocityY < -400)

        withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) {
            if shouldExpand {
                isExpanded = true
                expandProgress = 1
            } else if shouldCollapse {
                isExpanded = false
                expandProgress = 0
            } else {
                expandProgress = isExpanded ? 1 : 0
            }
        }
    }

    private func resetVerticalState() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) {
            expandProgress = isExpanded ? 1 : 0
        }
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }

    private func monthRowCount(for month: Date) -> Int {
        let cells = monthGridDays(
            for: month,
            showsOutOfMonthDays: showsOutOfMonthDays,
            alwaysSixWeeks: alwaysSixWeeks
        )
        return max(1, Int(ceil(Double(cells.count) / 7.0)))
    }

    private func adjacentDate(direction: CGFloat) -> Date {
        if isExpanded {
            return calendar.date(byAdding: .month, value: direction > 0 ? 1 : -1, to: displayedDate) ?? displayedDate
        } else {
            return calendar.date(byAdding: .weekOfYear, value: direction > 0 ? 1 : -1, to: displayedDate) ?? displayedDate
        }
    }

    private func commitSlide(direction: CGFloat, width: CGFloat) {
        withAnimation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.82)) {
            slideOffset = direction * width
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            if let incoming = incomingDate {
                displayedDate = incoming
            }
            slideOffset = 0
            incomingDate = nil
            incomingDirection = 0
        }
    }

    private func cancelSlide() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.88)) {
            slideOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            incomingDate = nil
            incomingDirection = 0
        }
    }

    private func startOfWeek(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let diff = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -diff, to: calendar.startOfDay(for: date)) ?? date
    }

    private func monthGridDays(
        for month: Date,
        showsOutOfMonthDays: Bool,
        alwaysSixWeeks: Bool
    ) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }

        let firstOfMonth = monthInterval.start
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let leading = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        let numberOfDays = calendar.range(of: .day, in: .month, for: month)?.count ?? 0

        if showsOutOfMonthDays {
            let start = calendar.date(byAdding: .day, value: -leading, to: firstOfMonth) ?? firstOfMonth
            let total: Int
            if alwaysSixWeeks {
                total = 42
            } else {
                let raw = leading + numberOfDays
                let rem = raw % 7
                total = rem == 0 ? raw : raw + (7 - rem)
            }
            return (0..<total).map { i in
                calendar.date(byAdding: .day, value: i, to: start)
            }
        } else {
            var cells = [Date?]()
            cells.append(contentsOf: Array(repeating: nil, count: leading))
            for dayOffset in 0..<numberOfDays {
                cells.append(calendar.date(byAdding: .day, value: dayOffset, to: firstOfMonth))
            }
            let remainder = cells.count % 7
            if remainder != 0 {
                cells.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
            }
            if alwaysSixWeeks && cells.count < 42 {
                cells.append(contentsOf: Array(repeating: nil, count: 42 - cells.count))
            }
            return cells
        }
    }
}
