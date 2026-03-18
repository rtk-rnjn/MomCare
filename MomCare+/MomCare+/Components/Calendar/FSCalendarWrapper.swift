import FSCalendar
import SwiftUI

struct FSCalendarView: UIViewRepresentable {
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {

        // MARK: Lifecycle

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: FSCalendarView
        weak var calendar: FSCalendar?

        func calendar(_: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
            DispatchQueue.main.async {
                self.parent.selectedDate = date
            }
        }
    }

    @Binding var selectedDate: Date

    var scope: FSCalendarScope
    var accentColor: UIColor = .init(Color.CustomColors.mutedRaspberry)

    func makeUIView(context: Context) -> FSCalendarContainerView {
        let container = FSCalendarContainerView(scope: scope)
        container.calendar.delegate = context.coordinator
        container.calendar.dataSource = context.coordinator

        let calendar = container.calendar

        calendar.appearance.weekdayTextColor = .secondaryLabel
        calendar.appearance.weekdayFont = .systemFont(ofSize: 13, weight: .medium)
        calendar.appearance.titleFont = .systemFont(ofSize: 16, weight: .regular)

        calendar.appearance.selectionColor = accentColor
        calendar.appearance.todayColor = accentColor.withAlphaComponent(0.15)
        calendar.appearance.todaySelectionColor = accentColor
        calendar.appearance.titleTodayColor = accentColor
        calendar.appearance.titleSelectionColor = .white

        calendar.appearance.titleDefaultColor = .label
        calendar.appearance.titleWeekendColor = .label

        calendar.scope = scope
        calendar.scrollDirection = .horizontal
        calendar.pagingEnabled = true
        calendar.firstWeekday = 1

        calendar.headerHeight = 0
        calendar.appearance.headerMinimumDissolvedAlpha = 0

        calendar.select(selectedDate)

        context.coordinator.calendar = calendar

        return container
    }

    func updateUIView(_: FSCalendarContainerView, context: Context) {
        guard let calendar = context.coordinator.calendar else { return }
        if let current = calendar.selectedDate, !Calendar.current.isDate(current, inSameDayAs: selectedDate) {
            calendar.select(selectedDate, scrollToDate: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

}

class FSCalendarContainerView: UIView {

    // MARK: Lifecycle

    init(scope: FSCalendarScope) {
        calendarScope = scope
        super.init(frame: .zero)
        setupCalendar()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let calendar: FSCalendar = .init()

    // MARK: Private

    private let calendarScope: FSCalendarScope

    private func setupCalendar() {
        calendar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(calendar)

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: topAnchor),
            calendar.leadingAnchor.constraint(equalTo: leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: trailingAnchor),
            calendar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}

class FSCalendarHostingController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    // MARK: Internal

    var onDateSelected: ((Date) -> Void)?

    var selectedDate: Date = .init() {
        didSet {
            if calendar != nil, !Calendar.current.isDate(calendar.selectedDate ?? Date(), inSameDayAs: selectedDate) {
                calendar.select(selectedDate, scrollToDate: true)
            }
        }
    }

    var scope: FSCalendarScope = .week {
        didSet {
            if calendar != nil, calendar.scope != scope {
                calendar.setScope(scope, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCalendar()
    }

    func calendar(_: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        onDateSelected?(date)
    }

    func calendar(_: FSCalendar, boundingRectWillChange bounds: CGRect, animated _: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }

    // MARK: Private

    private var calendar: FSCalendar!
    private var calendarHeightConstraint: NSLayoutConstraint!

    private func setupCalendar() {
        calendar = FSCalendar(frame: .zero)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.delegate = self
        calendar.dataSource = self

        calendar.scope = scope
        calendar.scrollDirection = .horizontal
        calendar.pagingEnabled = true
        calendar.firstWeekday = 1

        calendar.headerHeight = 24
        calendar.weekdayHeight = 18
        calendar.rowHeight = 28
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0

        let accentColor = UIColor(red: 139 / 255, green: 69 / 255, blue: 87 / 255, alpha: 1)
        calendar.appearance.headerTitleColor = .secondaryLabel
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 14, weight: .medium)
        calendar.appearance.weekdayTextColor = .secondaryLabel
        calendar.appearance.weekdayFont = .systemFont(ofSize: 11, weight: .medium)
        calendar.appearance.titleFont = .systemFont(ofSize: 13, weight: .regular)
        calendar.appearance.selectionColor = accentColor
        calendar.appearance.todayColor = accentColor.withAlphaComponent(0.15)
        calendar.appearance.todaySelectionColor = accentColor
        calendar.appearance.titleTodayColor = accentColor
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.titleDefaultColor = .label
        calendar.appearance.titleWeekendColor = .secondaryLabel

        calendar.backgroundColor = .clear

        view.addSubview(calendar)

        calendarHeightConstraint = calendar.heightAnchor.constraint(equalToConstant: 300)

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            calendar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            calendarHeightConstraint
        ])

        calendar.select(selectedDate)
    }

}

struct FSCalendarController: UIViewControllerRepresentable {
    @Binding var selectedDate: Date
    @Binding var scope: FSCalendarScope

    func makeUIViewController(context _: Context) -> FSCalendarHostingController {
        let controller = FSCalendarHostingController()
        controller.selectedDate = selectedDate
        controller.scope = scope
        controller.onDateSelected = { date in
            DispatchQueue.main.async {
                selectedDate = date
            }
        }
        return controller
    }

    func updateUIViewController(_ controller: FSCalendarHostingController, context _: Context) {
        controller.selectedDate = selectedDate
        controller.scope = scope
    }
}

struct CompactCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var isExpanded: Bool

    @State private var slideOffset: CGFloat = 0
    @State private var displayedDate: Date = Date()
    @State private var incomingDate: Date? = nil
    @State private var incomingDirection: CGFloat = 0
    @State private var isDraggingHorizontal: Bool? = nil

    // Vertical drag state
    @State private var verticalDragOffset: CGFloat = 0
    @State private var expandProgress: CGFloat = 0 // 0 = collapsed, 1 = expanded

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                        expandProgress = isExpanded ? 1 : 0
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(displayedDate.formatted(.dateTime.month(.wide).year()))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .id(displayedDate)
                            .transition(.push(from: incomingDirection > 0 ? .trailing : .leading))
                            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: displayedDate)

                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(expandProgress * -180))
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: expandProgress)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            GeometryReader { geo in
                let width = geo.size.width

                ZStack(alignment: .top) {
                    // Week strip — visible when collapsed
                    WeekStripView(date: displayedDate, selectedDate: $selectedDate)
                        .offset(x: slideOffset)
                        .frame(width: width)
                        .opacity(Double(1 - expandProgress))
                        .offset(y: -expandProgress * 20)

                    // Month grid — visible when expanded
                    MonthGridView(date: displayedDate, selectedDate: $selectedDate)
                        .offset(x: slideOffset)
                        .frame(width: width)
                        .opacity(Double(expandProgress))
                        .offset(y: (1 - expandProgress) * 20)

                    // Incoming slide view
                    if let incoming = incomingDate {
                        Group {
                            if isExpanded {
                                MonthGridView(date: incoming, selectedDate: $selectedDate)
                            } else {
                                WeekStripView(date: incoming, selectedDate: $selectedDate)
                            }
                        }
                        .offset(x: slideOffset + incomingDirection * width)
                        .frame(width: width)
                    }
                }
                .clipped()
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            let h = value.translation.width
                            let v = value.translation.height

                            if isDraggingHorizontal == nil {
                                if abs(h) > abs(v) + 5 {
                                    isDraggingHorizontal = true
                                } else if abs(v) > abs(h) + 5 {
                                    isDraggingHorizontal = false
                                }
                            }

                            if isDraggingHorizontal == true {
                                let direction: CGFloat = h < 0 ? -1 : 1
                                if incomingDate == nil {
                                    incomingDirection = -direction
                                    incomingDate = adjacentDate(direction: -direction)
                                }
                                slideOffset = h

                            } else if isDraggingHorizontal == false {
                                // Drive expandProgress live from drag
                                if !isExpanded {
                                    // dragging down → expanding
                                    let progress = min(max(v / expandTravelDistance, 0), 1)
                                    expandProgress = progress
                                } else {
                                    // dragging up → collapsing
                                    let progress = min(max(1 + v / expandTravelDistance, 0), 1)
                                    expandProgress = progress
                                }
                            }
                        }
                        .onEnded { value in
                            let h = value.translation.width
                            _ = value.translation.height
                            let velocityX = value.velocity.width
                            let velocityY = value.velocity.height

                            if isDraggingHorizontal == true {
                                let direction: CGFloat = h < 0 ? -1 : 1
                                let shouldCommit = abs(h) > 30 || abs(velocityX) > 300
                                if shouldCommit {
                                    commitSlide(direction: direction, width: width)
                                } else {
                                    cancelSlide()
                                }

                            } else if isDraggingHorizontal == false {
                                let shouldExpand = !isExpanded && (expandProgress > 0.4 || velocityY > 400)
                                let shouldCollapse = isExpanded && (expandProgress < 0.6 || velocityY < -400)

                                if shouldExpand {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isExpanded = true
                                        expandProgress = 1
                                    }
                                } else if shouldCollapse {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isExpanded = false
                                        expandProgress = 0
                                    }
                                } else {
                                    // Snap back
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        expandProgress = isExpanded ? 1 : 0
                                    }
                                }
                            } else {
                                cancelSlide()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    expandProgress = isExpanded ? 1 : 0
                                }
                            }

                            isDraggingHorizontal = nil
                        }
                )
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandProgress = newValue ? 1 : 0
            }
        }
    }

    // MARK: - Heights

    private var compactHeight: CGFloat { 80 }

    private var expandedHeight: CGFloat {
        let rowCount = Int(ceil(Double(calendar.generateDays(for: displayedDate).count) / 7.0))
        return CGFloat(rowCount) * 44 + 40
    }

    // Distance the user needs to drag to fully expand/collapse
    private var expandTravelDistance: CGFloat { 120 }

    // Live interpolated height during drag
    private var currentHeight: CGFloat {
        compactHeight + (expandedHeight - compactHeight) * expandProgress
    }

    // MARK: - Navigation

    private func adjacentDate(direction: CGFloat) -> Date {
        if isExpanded {
            return calendar.date(byAdding: .month, value: direction > 0 ? 1 : -1, to: displayedDate) ?? displayedDate
        } else {
            return calendar.date(byAdding: .weekOfYear, value: direction > 0 ? 1 : -1, to: displayedDate) ?? displayedDate
        }
    }

    private func commitSlide(direction: CGFloat, width: CGFloat) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
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
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            slideOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            incomingDate = nil
            incomingDirection = 0
        }
    }
}

struct WeekStripView: View {
    let date: Date
    @Binding var selectedDate: Date

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { d in
                DayCell(date: d, selectedDate: $selectedDate, showWeekday: true)
            }
        }
    }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

// MARK: - Month Grid View

struct MonthGridView: View {
    let date: Date
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 4) {
            // Weekday column headers
            HStack(spacing: 0) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(monthDays.enumerated()), id: \.offset) { _, d in
                    if let d {
                        DayCell(date: d, selectedDate: $selectedDate, showWeekday: false)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }

    private var monthDays: [Date?] {
        calendar.generateDays(for: date)
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    var showWeekday: Bool = true

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: showWeekday ? 6 : 2) {
                if showWeekday {
                    Text(date.formatted(.dateTime.weekday(.short)))
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondary)
                }

                Text(date.formatted(.dateTime.day()))
                    .font(.body.weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? Color.CustomColors.mutedRaspberry : .primary))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.CustomColors.mutedRaspberry : Color.clear)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func generateDays(for date: Date) -> [Date?] {
        guard let monthInterval = self.dateInterval(of: .month, for: date) else { return [] }

        let firstDay = monthInterval.start
        let firstWeekday = self.component(.weekday, from: firstDay)
        let leadingEmpties = (firstWeekday - self.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingEmpties)

        var current = firstDay
        while self.isDate(current, equalTo: firstDay, toGranularity: .month) {
            days.append(current)
            guard let next = self.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return days
    }
}
