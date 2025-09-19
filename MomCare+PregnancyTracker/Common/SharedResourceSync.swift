//
//  SharedResourceSync.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import Foundation

enum SharedResourceSync {
    private static var suite: UserDefaults? {
        UserDefaults(suiteName: "group.MomCare")
    }
    
    // MARK: - Fetch User
    static func fetchFromUserDefaults() -> User? {
        guard let data = suite?.value(forKey: "user") as? Data else {
            return nil
        }
        return try? PropertyListDecoder().decode(User.self, from: data)
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
    
    // MARK: - MyPlan Fetching
    
    static func saveMyPlan(_ plan: MyPlan) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(plan) {
            suite?.set(data, forKey: "userPlan")
        }
    }
    
    static func getMyPlan() -> MyPlan? {
        guard let data = suite?.data(forKey: "userPlan") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(MyPlan.self, from: data)
    }
    
    // MARK: - MyPlan Stats for Widget
    
    static func getTotalCalories() -> Double {
        return getMyPlan()?.totalCalories ?? 0
    }
    
    static func getTotalProtein() -> Double {
        return getMyPlan()?.totalProtien ?? 0
    }
    
    static func getTotalCarbs() -> Double {
        return getMyPlan()?.totalCarbs ?? 0
    }
    
    static func getTotalFat() -> Double {
        return getMyPlan()?.totalFat ?? 0
    }
}


