import Foundation

extension Date {
    func relativeString(from date: Date?) -> String {
        guard let date else { return "just now" }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]
        formatter.maximumUnitCount = 1

        let now = Date()
        let timeInterval = round(now.timeIntervalSince(date))

        if let formattedString = formatter.string(from: abs(timeInterval)) {
            return timeInterval < 0 ? "in \(formattedString)" : "\(formattedString) ago"
        } else {
            return "just now"
        }
    }

    func relativeInterval(from date: Date?) -> TimeInterval {
        guard let date else { return 0 }
        return abs(round(Date().timeIntervalSince(date)))
    }
}
