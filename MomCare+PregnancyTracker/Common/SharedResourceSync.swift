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

    static func getPregnancyData() -> (week: Int, day: Int, trimester: String)? {
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
        return getPregnancyData()?.trimester ?? "Invalid Trimester"
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
