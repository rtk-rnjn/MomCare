import SwiftUI

struct MonthGridView: View {

    // MARK: Internal

    let date: Date
    @Binding var selectedDate: Date

    var showsOutOfMonthDays: Bool = false
    var alwaysSixWeeks: Bool = true

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(calendar.orderedShortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, d in
                    if let d {
                        DayCell(date: d, selectedDate: $selectedDate, showWeekday: false)
                            .opacity(isInDisplayedMonth(d) ? 1.0 : (showsOutOfMonthDays ? 0.35 : 1.0))
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }

    // MARK: Private

    private let calendar: Calendar = .current
    private let columns: Array = .init(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var cells: [Date?] {
        calendar.monthGridDays(
            for: date,
            showsOutOfMonthDays: showsOutOfMonthDays,
            alwaysSixWeeks: alwaysSixWeeks
        )
    }

    private func isInDisplayedMonth(_ d: Date) -> Bool {
        calendar.isDate(d, equalTo: date, toGranularity: .month)
    }
}
