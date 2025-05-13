//
//  MyPlanMLModel.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/03/25.
//

import Foundation

enum SampleFoodData {
    public static let uniqueFoodItems: [FoodItem] = [
        FoodItem(name: "Moong Dal Cheela", imageUri: "moong-dal-cheela", calories: 120, protein: 8, carbs: 15, fat: 2),
        FoodItem(name: "Anda Bhurji", imageUri: "anda-bhurji", calories: 150, protein: 12, carbs: 2, fat: 10),
        FoodItem(name: "Chole Chawal", imageUri: "chole-chawal", calories: 350, protein: 12, carbs: 50, fat: 8),
        FoodItem(name: "Aloo Matar", imageUri: "aloo-matar", calories: 200, protein: 6, carbs: 30, fat: 5),
        FoodItem(name: "Amritsari Kulcha", imageUri: "amritsari-kulcha", calories: 250, protein: 6, carbs: 40, fat: 8),
        FoodItem(name: "Aloo Chaat", imageUri: "aloo-chaat", calories: 180, protein: 3, carbs: 25, fat: 8),
        FoodItem(name: "Halwa", imageUri: "Halwa", calories: 300, protein: 4, carbs: 40, fat: 15),
        FoodItem(name: "Aloo Paratha", imageUri: "aloo-paratha", calories: 280, protein: 6, carbs: 40, fat: 10)
    ]
}

class MyPlanMLModel {
    static func fetchPlans(from userMedical: UserMedical) async -> MyPlan {
        let plan: MyPlan? = await NetworkManager.shared.get(url: "/plan")
        guard let plan else {
            return MyPlan()
        }
        return plan
    }
}
