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
