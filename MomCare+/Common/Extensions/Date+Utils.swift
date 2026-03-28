import Foundation

extension Date {
    nonisolated var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    nonisolated var nextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }
}
