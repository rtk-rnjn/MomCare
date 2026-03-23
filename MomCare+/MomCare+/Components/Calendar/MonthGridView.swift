import SwiftUI

struct MonthGridView: View {
    // MARK: Internal

    let date: Date
    @Binding var selectedDate: Date

    var showsOutOfMonthDays: Bool
    var alwaysSixWeeks: Bool
    var cellHeight: CGFloat
    var headerBottomPadding: CGFloat

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(orderedWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, headerBottomPadding)
            .accessibilityHidden(true)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, date in
                    if let date {
                        DayCell(date: date, selectedDate: $selectedDate, showWeekday: false)
                            .opacity(isInDisplayedMonth(date) ? 1.0 : (showsOutOfMonthDays ? 0.35 : 1.0))
                            .frame(height: cellHeight)
                    } else {
                        Color.clear
.frame(height: cellHeight)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
    }

    // MARK: Private

    private let calendar: Calendar = .current
    private let columns: Array = .init(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var orderedWeekdaySymbols: [String] {
        Calendar.current.orderedShortWeekdaySymbols
    }

    private var cells: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }

        let firstOfMonth = monthInterval.start
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let leading = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        let numberOfDays = calendar.range(of: .day, in: .month, for: date)?.count ?? 0

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
            var out = [Date?]()
            out.append(contentsOf: Array(repeating: nil, count: leading))
            for dayOffset in 0..<numberOfDays {
                out.append(calendar.date(byAdding: .day, value: dayOffset, to: firstOfMonth))
            }
            let remainder = out.count % 7
            if remainder != 0 {
                out.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
            }
            if alwaysSixWeeks, out.count < 42 {
                out.append(contentsOf: Array(repeating: nil, count: 42 - out.count))
            }
            return out
        }
    }

    private func isInDisplayedMonth(_ d: Date) -> Bool {
        calendar.isDate(d, equalTo: date, toGranularity: .month)
    }
}
