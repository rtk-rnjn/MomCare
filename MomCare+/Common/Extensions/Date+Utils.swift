import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var nextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }
}
