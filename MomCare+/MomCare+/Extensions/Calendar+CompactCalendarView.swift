import Foundation

extension Calendar {

    var orderedShortWeekdaySymbols: [String] {
        let symbols = shortWeekdaySymbols

        let startIndex = firstWeekday - 1
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    func monthGridDays(
        for month: Date,
        showsOutOfMonthDays: Bool = false,
        alwaysSixWeeks: Bool = true
    ) -> [Date?] {
        guard let monthInterval = dateInterval(of: .month, for: month) else { return [] }

        let firstOfMonth = monthInterval.start

        let weekdayOfFirst = component(.weekday, from: firstOfMonth)
        let leading = (weekdayOfFirst - firstWeekday + 7) % 7

        let numberOfDays = range(of: .day, in: .month, for: month)?.count ?? 0

        var cells = [Date?]()
        cells.reserveCapacity(42)

        if showsOutOfMonthDays {

            let start = date(byAdding: .day, value: -leading, to: firstOfMonth) ?? firstOfMonth
            let total = alwaysSixWeeks ? 42 : {

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

            cells.append(contentsOf: Array(repeating: nil, count: leading))

            for dayOffset in 0..<numberOfDays {
                let d = date(byAdding: .day, value: dayOffset, to: firstOfMonth)
                cells.append(d)
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

    func startOfWeek(for date: Date) -> Date {

        let weekday = component(.weekday, from: date)
        let diff = (weekday - firstWeekday + 7) % 7
        return self.date(byAdding: .day, value: -diff, to: startOfDay(for: date)) ?? date
    }
}
