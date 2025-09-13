//
//  SharedResourceSync.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import Foundation

enum SharedResourceSync {
    static func fetchFromUserDefaults() -> User? {
        if let data = UserDefaults(suiteName: "group.MomCare")?.value(forKey: "user") as? Data {
            return try? PropertyListDecoder().decode(User.self, from: data)
        }

        return nil
    }

    static func getPregnancyData() -> (week: Int, day: Int, trimester: String)? { // swiftlint:disable:this large_tuple
        let user = fetchFromUserDefaults()
        return user?.pregancyData
    }

    static func getWeek() -> Int {
        return getPregnancyData()?.week ?? 0
    }

    static func getDay() -> Int {
        return getPregnancyData()?.day ?? 0
    }
    
    static func getTrimester() -> String {
        return getPregnancyData()?.trimester ?? "Invalid Trimester fetched"
    }
    
    static func getNextReminder(completion: @Sendable @escaping (String?) -> Void) {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? Date()

        Task {
            await EventKitHandler.shared.fetchReminders(startDate: startDate, endDate: endDate) { reminders in
                let sortedReminders = reminders.sorted {
                    ($0.dueDateComponents?.date ?? Date()) < ($1.dueDateComponents?.date ?? Date())
                }
                let nextReminderTitle = sortedReminders.first?.title
                completion(nextReminderTitle)
            }
        }
    }
    
    static func getBabyFruit(for week: Int) -> (fruitName: String, fruitImageURL: String)? {
        guard let trimesterData = TriTrackData.getTrimesterData(for: week) else {
            return nil
        }

        let fruitName = trimesterData.quote ?? "Unknown Fruit"
        let fruitImageURL = trimesterData.imageUri ?? ""

        return (fruitName, fruitImageURL)
    }
}
