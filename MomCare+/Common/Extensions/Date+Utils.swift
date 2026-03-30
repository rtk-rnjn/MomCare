import Foundation

extension Date {
    nonisolated var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    nonisolated var nextDay: Date {
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) {
            return date
        }

        fatalError(Quote.randomQuote.displayString)
    }
}
