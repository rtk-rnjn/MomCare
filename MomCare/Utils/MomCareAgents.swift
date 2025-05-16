//
//  MomCareAgents.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/03/25.
//

import Foundation

struct Tip: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case todaysFocus = "todays_focus"
        case dailyTip = "daily_tip"
    }

    var todaysFocus: String
    var dailyTip: String

}

struct FoodSearchQuery: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case limit
    }

    var foodName: String
    var limit: Int = 10
}

class MomCareAgents {

    // MARK: Public

    public static var shared: MomCareAgents = .init()

    // MARK: Internal

    var plan: MyPlan?
    var tips: Tip?

    @discardableResult
    func fetchPlan(from userMedical: UserMedical) async -> MyPlan {
        if let plan {
            return plan
        }

        let plan: MyPlan? = await NetworkManager.shared.get(url: "/plan")
        guard let plan else {
            return MyPlan()
        }

        self.plan = plan
        return plan
    }

    @discardableResult
    func fetchTips(from user: User) async -> Tip {
        if let tips {
            return tips
        }

        let tips: Tip? = await NetworkManager.shared.get(url: "/plan/tips")
        guard let tips else {
            return Tip(todaysFocus: "Unable to fetch Today's Focus from the server", dailyTip: "Unable to fetch Daily Tip from the server")
        }

        self.tips = tips
        return tips
    }

    func searchFoods(with query: String) async -> [FoodItem] {
        let searchQeury = FoodSearchQuery(foodName: query)
        let _sendableQeury: [String: Any]? = searchQeury.toDictionary(snakeCase: true)

        let foods: [FoodItem]? = await NetworkManager.shared.get(url: "/plan/search", queryParameters: _sendableQeury)

        guard let foods else {
            return []
        }

        return foods
    }

    // MARK: Private

    private func fetchFromUserDefaults() -> Tip? {
        guard let data = UserDefaults.standard.data(forKey: "tips") else { return nil }

        return try? JSONDecoder().decode(Tip.self, from: data)
    }

    private func saveToUserDefaults(_ tips: Tip) {
        guard let data = tips.toData() else {
            return
        }
        UserDefaults.standard.set(data, forKey: "tips")
    }

}
