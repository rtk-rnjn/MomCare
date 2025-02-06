//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

class MomCareUser {

    // MARK: Lifecycle

    private init() {
        updateFromDatabase()

        // TODO: Remove this
        _ = getCurrentUser()
    }

    // MARK: Internal

    static var shared: MomCareUser = .init()

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

    func updateToDatabase() {}

    // MARK: Private

    private func updateFromDatabase() {}

}
