//
//  Utils.swift
//  MomCare+
//
//  Created by Aryan singh on 13/02/26.
//

import Foundation

struct DashboardPregnancyProgress {
    let week: Int
    let day: Int
    let trimester: String
    let isValid: Bool
}

private let totalDays = 280

enum Utils {
    static func progress(fromDueDate dueDate: Date, today: Date = Date()) -> DashboardPregnancyProgress {
        let calendar = Calendar.current

        guard let startDate = calendar.date(byAdding: .day, value: -totalDays, to: dueDate) else {
            return DashboardPregnancyProgress(week: 0, day: 0, trimester: "—", isValid: false)
        }

        let daysPassed = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0

        let clampedDays = max(0, min(daysPassed, totalDays))

        let week = clampedDays / 7 + 1
        let day = clampedDays % 7 + 1

        let trimester = switch week {
        case 1 ... 13:
            "I"
        case 14 ... 27:
            "II"
        default:
            "III"
        }

        return DashboardPregnancyProgress(
            week: week,
            day: day,
            trimester: trimester,
            isValid: true
        )
    }

    static func weekRange(containing date: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
            fatalError("Could not calculate week range")
        }

        return (0 ..< 7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    static func formattedTime(_ time: TimeInterval) -> String {
        Duration.seconds(time).formatted(.time(pattern: .hourMinuteSecond))
    }
}
