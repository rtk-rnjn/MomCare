import SwiftUI

struct WeekStripView: View {
    // MARK: Internal

    let date: Date

    @Binding var selectedDate: Date

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { d in
                DayCell(date: d, selectedDate: $selectedDate, showWeekday: true)
            }
        }
    }

    // MARK: Private

    private let calendar: Calendar = .current

    private var weekDays: [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let diff = (weekday - calendar.firstWeekday + 7) % 7
        let start = calendar.date(byAdding: .day, value: -diff, to: calendar.startOfDay(for: date)) ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
}
