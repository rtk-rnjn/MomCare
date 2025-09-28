//
//  Date+Relative.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import Foundation

extension Date {
    /// Returns a human-readable relative time string between the current date and a given date.
    ///
    /// Uses `DateComponentsFormatter` to produce strings like:
    /// - `"5 minutes ago"`
    /// - `"2 days ago"`
    /// - `"in 3 hours"`
    ///
    /// If the given date is `nil`, it defaults to `"just now"`.
    ///
    /// - Parameter date: The reference `Date` to compare against the current time.
    /// - Returns: A localized, human-readable relative time string.
    ///
    /// ### Usage
    /// ```swift
    /// let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
    /// let relative = Date().relativeString(from: pastDate)
    /// // "1 hour ago"
    ///
    /// let futureDate = Date().addingTimeInterval(600) // 10 minutes later
    /// let relative = Date().relativeString(from: futureDate)
    /// // "in 10 minutes"
    /// ```
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

    /// Returns the absolute time interval in seconds between the current date and a given date.
    ///
    /// - Parameter date: The reference `Date` to compare against the current time.
    /// - Returns: The rounded absolute difference in seconds. Returns `0` if the date is `nil`.
    ///
    /// ### Usage
    /// ```swift
    /// let pastDate = Date().addingTimeInterval(-90) // 1.5 minutes ago
    /// let interval = Date().relativeInterval(from: pastDate)
    /// // 90.0
    /// ```
    func relativeInterval(from date: Date?) -> TimeInterval {
        guard let date else { return 0 }
        return abs(round(Date().timeIntervalSince(date)))
    }
}
