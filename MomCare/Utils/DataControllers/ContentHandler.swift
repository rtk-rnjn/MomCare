//
//  ContentHandler.swift
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

struct MediaLink: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case uri = "link"
        case expiryAt = "link_expiry_at"
    }

    var uri: String
    var expiryAt: Date?
}

class ContentHandler {

    // MARK: Public

    public static var shared: ContentHandler = .init()

    // MARK: Internal

    var plan: MyPlan?
    var tips: Tip?

    @discardableResult
    func fetchPlan(from userMedical: UserMedical) async -> MyPlan {
        if let plan {
            return plan
        }

        let plan: MyPlan? = await NetworkManager.shared.get(url: "/content/plan")
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

        let tips: Tip? = await NetworkManager.shared.get(url: "/content/tips")
        guard let tips else {
            return Tip(todaysFocus: "Unable to fetch Today's Focus from the server", dailyTip: "Unable to fetch Daily Tip from the server")
        }

        self.tips = tips
        return tips
    }

    func searchFoods(with query: String) async -> [FoodItem] {
        let searchQeury = FoodSearchQuery(foodName: query)
        let _sendableQeury: [String: Any]? = searchQeury.toDictionary(snakeCase: true)

        let foods: [FoodItem]? = await NetworkManager.shared.get(url: "/content/search", queryParameters: _sendableQeury)

        guard let foods else {
            return []
        }

        return foods
    }

    func fetchTune(tuneType: String, category: String, fileName: String) async -> MediaLink? {
        let path = "/content/tunes/\(tuneType)/\(category)/\(fileName)"

        return await NetworkManager.shared.get(url: path)
    }

    func fetchAudio(from url: String) async -> Data? {
        guard let url = URL(string: url) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            return nil
        }
    }

    func saveDataToFileSystem(path: String, data: Data) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(path)

        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving file: \(error)")
        }
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
