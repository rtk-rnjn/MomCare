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

    @State private var dragOffset: CGFloat = 0
    @State private var slideOffset: CGFloat = 0
    @State private var weekOffset: Int = 0
    @State private var slideDirection: CGFloat = 0

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            ZStack {
                if isExpanded {
                    MonthGridView(selectedDate: $selectedDate)
                        .offset(x: slideOffset)
                        .transition(.opacity)
                } else {
                    WeekStripView(selectedDate: $selectedDate)
                        .offset(x: slideOffset)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
            .clipped()
        }
        .background(Color(.systemBackground))
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let isHorizontal = abs(horizontal) > abs(vertical)

                    if isHorizontal {
                        // Live drag tracking
                        withAnimation(.interactiveSpring()) {
                            slideOffset = horizontal * 0.6
                        }
                    } else {
                        dragOffset = vertical
                    }
                }
                .onEnded { value in
                    let threshold: CGFloat = 40
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let isHorizontal = abs(horizontal) > abs(vertical)

                    if isHorizontal {
                        if horizontal < -threshold {
                            navigateForward()
                        } else if horizontal > threshold {
                            navigateBackward()
                        } else {
                            // Snap back
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                slideOffset = 0
                            }
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if vertical > threshold && !isExpanded {
                                isExpanded = true
                            } else if vertical < -threshold && isExpanded {
                                isExpanded = false
                            }
                        }
                        dragOffset = 0
                    }
                }
        )
    }

    private func navigateForward() {
        let screenWidth = UIScreen.current.bounds.width
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideOffset = -screenWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            slideOffset = screenWidth
            if isExpanded {
                selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
            } else {
                selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                slideOffset = 0
            }
        }
    }

    private func navigateBackward() {
        let screenWidth = UIScreen.current.bounds.width
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            slideOffset = screenWidth
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            slideOffset = -screenWidth
            if isExpanded {
                selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
            } else {
                selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                slideOffset = 0
            }
        }
    }
}

struct WeekStripView: View {
    @Binding var selectedDate: Date

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                DayCell(date: date, selectedDate: $selectedDate, showWeekday: true)
            }
        }
    }

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}


struct MonthGridView: View {
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

            // Day grid — no weekday labels inside cells
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                    if let date {
                        DayCell(date: date, selectedDate: $selectedDate, showWeekday: false)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }

    private var monthDays: [Date?] {
        calendar.generateDays(for: selectedDate)
    }
}


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
