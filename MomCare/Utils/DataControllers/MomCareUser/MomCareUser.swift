//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

@MainActor
class MomCareUser {

    // MARK: Public

    public static var shared: MomCareUser = .init()

    public private(set) var user: User? {
        didSet {
            if oldValue != user {
                updateToDatabase()
            }
        }
    }

    // MARK: Internal

    let queue: DispatchQueue = .init(label: "MomCareUserQueue")

    // https://medium.com/@harshaag99/understanding-dispatchqueue-in-swift-c73058df6b37

    func updateFromDatabase() {
        queue.async {
            Task {
                await self.fetchUser(from: .database)
            }
        }
    }

    func updateToDatabase() {
        queue.async {
            Task {
                await self.updateUser(to: .database)
            }
        }
    }

    func setMedicalData(_ data: UserMedical) {
        user?.medicalData = data
    }

    func setCurrentMood(as mood: MoodType) {
        user?.mood = mood
    }

    func setUser(_ user: User) {
        self.user = user
    }

    func setUserPlan(_ plan: MyPlan) {
        user?.plan = plan
    }

    func addFoodItem(_ foodItem: FoodItem, to meal: MealType) {
        switch meal {
        case .breakfast:
            user?.plan.breakfast.append(foodItem)
        case .lunch:
            user?.plan.lunch.append(foodItem)
        case .snacks:
            user?.plan.snacks.append(foodItem)
        case .dinner:
            user?.plan.dinner.append(foodItem)
        }

    }

    func removeFoodItem(_ foodItem: FoodItem, from meal: MealType) {
        switch meal {
        case .breakfast:
            user?.plan.breakfast.removeAll { $0.name == foodItem.name }
        case .lunch:
            user?.plan.lunch.removeAll { $0.name == foodItem.name }
        case .snacks:
            user?.plan.snacks.removeAll { $0.name == foodItem.name }
        case .dinner:
            user?.plan.dinner.removeAll { $0.name == foodItem.name }
        }
    }

    func toggleConsumed(for foodItem: FoodItem, in meal: MealType) -> Bool? {

        switch meal {
        case .breakfast:
            if let index = user?.plan.breakfast.firstIndex(where: { $0.name == foodItem.name }) {
                user?.plan.breakfast[index].consumed.toggle()
                return user?.plan.breakfast[index].consumed
            }

        case .lunch:
            if let index = user?.plan.lunch.firstIndex(where: { $0.name == foodItem.name }) {
                user?.plan.lunch[index].consumed.toggle()
                return user?.plan.lunch[index].consumed
            }

        case .snacks:
            if let index = user?.plan.snacks.firstIndex(where: { $0.name == foodItem.name }) {
                user?.plan.snacks[index].consumed.toggle()
                return user?.plan.snacks[index].consumed
            }

        case .dinner:
            if let index = user?.plan.dinner.firstIndex(where: { $0.name == foodItem.name }) {
                user?.plan.dinner[index].consumed.toggle()
                return user?.plan.dinner[index].consumed
            }
        }
        return false
    }

    func markFoodsAsConsumed(in meal: MealType, consumed: Bool = true) {
        switch meal {
        case .breakfast:
            user?.plan.breakfast = user?.plan.breakfast.map { var item = $0; item.consumed = consumed; return item } ?? []
        case .lunch:
            user?.plan.lunch = user?.plan.lunch.map { var item = $0; item.consumed = consumed; return item } ?? []
        case .snacks:
            user?.plan.snacks = user?.plan.snacks.map { var item = $0; item.consumed = consumed; return item } ?? []
        case .dinner:
            user?.plan.dinner = user?.plan.dinner.map { var item = $0; item.consumed = consumed; return item } ?? []
        }
    }
}
