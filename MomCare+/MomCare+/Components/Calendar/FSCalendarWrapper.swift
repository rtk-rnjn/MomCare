

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

    // MARK: Internal

    override var intrinsicContentSize: CGSize {
        let height: CGFloat = calendarScope == .week ? 90 : 350
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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
            calendar.bottomAnchor.constraint(equalTo: bottomAnchor),
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
            calendarHeightConstraint,
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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Color.CustomColors.mutedRaspberry)
                        .padding(6)
                        .background(Color.CustomColors.mutedRaspberry.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            WeekStripView(selectedDate: $selectedDate)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
    }
}

struct WeekStripView: View {

    // MARK: Internal

    @Binding var selectedDate: Date

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                DayCell(date: date, selectedDate: $selectedDate)
            }
        }
    }

    // MARK: Private

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

}

struct DayCell: View {

    // MARK: Internal

    let date: Date

    @Binding var selectedDate: Date

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 6) {
                Text(date.formatted(.dateTime.weekday(.short)))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
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

    // MARK: Private

    private var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

}

struct ExpandedCalendarOverlay: View {
    @Binding var selectedDate: Date
    @Binding var isExpanded: Bool

    var body: some View {
        if isExpanded {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }

                VStack(spacing: 0) {
                    HStack {
                        Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isExpanded = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color(.secondarySystemFill))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    FSCalendarView(
                        selectedDate: $selectedDate,
                        scope: .month
                    )
                    .frame(height: 300)
                }
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.horizontal, 16)
                .padding(.top, 60)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .onChange(of: selectedDate) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                }
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    CompactCalendarView(selectedDate: .constant(Date()), isExpanded: .constant(false))
}
