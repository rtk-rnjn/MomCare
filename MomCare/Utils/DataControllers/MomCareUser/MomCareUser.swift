//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

struct UpdateResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case success
        case modifiedCount = "modified_count"
    }

    var success: Bool
    var modifiedCount: String

}

class MomCareUser {

    // MARK: Lifecycle

    private init() {
        updateFromDatabase()
    }

    // MARK: Internal

    @MainActor static var shared: MomCareUser = .init()

    var user: User?

    var meals: [MealType: [FoodItem]] = [
        .breakfast: [
            FoodItem(name: "Moong Dal Cheela", imageName: "moong-dal-cheela", calories: 120, protein: 8, carbs: 15, fat: 2),
            FoodItem(name: "Anda Bhurji", imageName: "anda-bhurji", calories: 150, protein: 12, carbs: 2, fat: 10)
        ],
        .lunch: [
            FoodItem(name: "Chole Chawal", imageName: "chole-chawal", calories: 350, protein: 12, carbs: 50, fat: 8),
            FoodItem(name: "Aloo Matar", imageName: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5),
            FoodItem(name: "Amritsari Kulcha", imageName: "amritsari-kulcha", calories: 250, protein: 6, carbs: 40, fat: 8)
        ],
        .snacks: [
            FoodItem(name: "Aloo Chaat", imageName: "aloo-chaat", calories: 180, protein: 3, carbs: 25, fat: 8),
            FoodItem(name: "Halwa", imageName: "halwa", calories: 300, protein: 4, carbs: 40, fat: 15)
        ],
        .dinner: [
            FoodItem(name: "Aloo Paratha", imageName: "aloo-paratha", calories: 280, protein: 6, carbs: 40, fat: 10),
            FoodItem(name: "Aloo Matar", imageName: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5)
        ]
    ]

    func setCurrentMood(as mood: MoodType) {
        user?.mood = mood
    }

    func updateToDatabase() {
        guard let user else { return }
        saveUserToUserDefaults(user: user)

        Task {
            var _: UpdateResponse? = await MiddlewareManager.shared.put(url: "/user/update", body: user.toData()!)
        }
    }

    func updateFromDatabase() {
        let mongoId = Utils.get(key: "mongoUserID", defaultValue: "nil")
        // We can't just use nil. cause the type of defaultvalue determines the type of the return value
        let cachedUser = retrieveUserFromUserDefaults()

        Task {
            if let cachedUser {
                self.user = await MiddlewareManager.shared.get(url: "/user/fetch", queryParameters: ["email": cachedUser.emailAddress, "password": cachedUser.password])
            }

            if mongoId != "nil" {
                self.user = await MiddlewareManager.shared.get(url: "/user/fetch/\(mongoId)")
            }

            print(self.user as Any)
        }
    }

}
