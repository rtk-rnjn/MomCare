import Foundation

extension Calendar {

    /// Returns weekday symbols ordered starting from calendar.firstWeekday.
    var orderedShortWeekdaySymbols: [String] {
        let symbols = self.shortWeekdaySymbols
        // firstWeekday is 1...7 (1=Sunday in Gregorian)
        let startIndex = firstWeekday - 1
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    /// FSCalendar-like month grid.
    ///
    /// - Parameters:
    ///   - month: Any date within the target month.
    ///   - showsOutOfMonthDays: If true, leading/trailing cells are filled with dates from adjacent months.
    ///   - alwaysSixWeeks: If true, grid is padded to 6 weeks (42 cells).
    func monthGridDays(
        for month: Date,
        showsOutOfMonthDays: Bool = false,
        alwaysSixWeeks: Bool = true
    ) -> [Date?] {
        guard let monthInterval = dateInterval(of: .month, for: month) else { return [] }

        let firstOfMonth = monthInterval.start

        // How many blanks before the 1st of month, respecting firstWeekday.
        // weekday: 1...7, firstWeekday: 1...7
        let weekdayOfFirst = component(.weekday, from: firstOfMonth)
        let leading = (weekdayOfFirst - firstWeekday + 7) % 7

        // Number of days in month
        let numberOfDays = range(of: .day, in: .month, for: month)?.count ?? 0

        var cells: [Date?] = []
        cells.reserveCapacity(42)

        if showsOutOfMonthDays {
            // Fill leading dates from previous month
            let start = date(byAdding: .day, value: -leading, to: firstOfMonth) ?? firstOfMonth
            let total = alwaysSixWeeks ? 42 : {
                // minimal rows: leading + numberOfDays, padded to full weeks
                let raw = leading + numberOfDays
                let remainder = raw % 7
                return remainder == 0 ? raw : (raw + (7 - remainder))
            }()

            for i in 0..<total {
                let d = date(byAdding: .day, value: i, to: start)
                cells.append(d)
            }
            return cells
        } else {
            // Leading empties
            cells.append(contentsOf: Array(repeating: nil, count: leading))

            // Days of month
            for dayOffset in 0..<numberOfDays {
                let d = date(byAdding: .day, value: dayOffset, to: firstOfMonth)
                cells.append(d)
            }

            // Trailing empties to complete weeks
            let remainder = cells.count % 7
            if remainder != 0 {
                cells.append(contentsOf: Array(repeating: nil, count: 7 - remainder))
            }

            // Pad to 6 rows if desired
            if alwaysSixWeeks && cells.count < 42 {
                cells.append(contentsOf: Array(repeating: nil, count: 42 - cells.count))
            }

            return cells
        }
    }

    /// Start of week for a given date respecting firstWeekday.
    func startOfWeek(for date: Date) -> Date {
        // dateInterval(of:.weekOfYear) respects calendar settings, but start depends on locale/firstWeekday
        // This approach is stable:
        let weekday = component(.weekday, from: date)
        let diff = (weekday - firstWeekday + 7) % 7
        return self.date(byAdding: .day, value: -diff, to: startOfDay(for: date)) ?? date
    }
}
