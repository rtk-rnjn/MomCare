import SwiftUI
import UIKit

struct CalendarRangePicker: UIViewRepresentable {

    final class Coordinator: NSObject, UICalendarSelectionMultiDateDelegate {

        // MARK: Lifecycle

        init(parent: CalendarRangePicker) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: CalendarRangePicker
        weak var selection: UICalendarSelectionMultiDate?

        func multiDateSelection(
            _ selection: UICalendarSelectionMultiDate,
            didSelectDate dateComponents: DateComponents
        ) {
            guard let date = Calendar.current.date(from: dateComponents) else { return }

            if let start = pendingStart {
                if date < start {
                    let range = date...start
                    applyRange(range, selection: selection)
                } else if date == start {
                    let range = start...start
                    applyRange(range, selection: selection)
                } else {
                    let range = start...date
                    applyRange(range, selection: selection)
                }
            } else {
                pendingStart = date
                selection.setSelectedDates(
                    [Calendar.current.dateComponents([.year, .month, .day], from: date)],
                    animated: true
                )
            }
        }

        func multiDateSelection(
            _ selection: UICalendarSelectionMultiDate,
            didDeselectDate dateComponents: DateComponents
        ) {
            // Reset when user deselects
            pendingStart = nil
            parent.selectedRange = nil
            selection.setSelectedDates([], animated: true)
        }

        func multiDateSelection(
            _ selection: UICalendarSelectionMultiDate,
            canSelectDate dateComponents: DateComponents
        ) -> Bool {
            guard let date = Calendar.current.date(from: dateComponents) else { return false }
            return date <= Date()
        }

        func multiDateSelection(
            _ selection: UICalendarSelectionMultiDate,
            canDeselectDate dateComponents: DateComponents
        ) -> Bool { true }

        // MARK: Private

        private var pendingStart: Date?

        private func applyRange(_ range: ClosedRange<Date>, selection: UICalendarSelectionMultiDate) {
            pendingStart = nil

            var dates = [DateComponents]()
            var cursor = range.lowerBound
            while cursor <= range.upperBound {
                dates.append(Calendar.current.dateComponents([.year, .month, .day], from: cursor))
                cursor = Calendar.current.date(byAdding: .day, value: 1, to: cursor)!
            }

            selection.setSelectedDates(dates, animated: true)
            parent.selectedRange = range
            parent.onRangeSelected?(range)
        }
    }

    @Binding var selectedRange: ClosedRange<Date>?

    var onRangeSelected: ((ClosedRange<Date>) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = .current
        view.locale = .current
        view.fontDesign = .rounded

        view.availableDateRange = DateInterval(
            start: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
            end: Date()
        )

        let selection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        context.coordinator.selection = selection
        view.selectionBehavior = selection

        return view
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        if let range = selectedRange {
            let components = stride(
                from: range.lowerBound,
                through: range.upperBound,
                by: 86_400
            ).map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }

            context.coordinator.selection?.setSelectedDates(components, animated: false)
        } else {
            context.coordinator.selection?.setSelectedDates([], animated: false)
        }
    }

}
