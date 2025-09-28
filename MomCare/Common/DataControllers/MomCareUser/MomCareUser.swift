//
//  MomCareUser.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/02/25.
//

import Foundation

/// `MomCareUser` is a singleton class responsible for managing the currently
/// authenticated user in the MomCare app. It handles local storage, database
/// updates, meal management, and access token refreshing.
///
/// Marked with `@MainActor` to ensure all UI-related updates occur on the main thread.
@MainActor
class MomCareUser {

    // MARK: Internal

    /// Shared singleton instance of `MomCareUser`.
    static var shared: MomCareUser = .init()

    /// Private dispatch queue for database operations to avoid blocking the main thread.
    let queue: DispatchQueue = .init(label: "MomCareUserQueue")

    /// Access token expiration date. When set, automatically schedules a refresh.
    var accessTokenExpiresAt: Date? {
        didSet {
            scheduleRefresh()
        }
    }

    /// Current authenticated user. Updates to this property automatically
    /// trigger local and database updates.
    var user: User? {
        didSet {
            guard let user, oldValue != user else { return }
            updateToDatabase()
            updateToUserDefaults()
        }
    }

    /// Saves the current `user` to the app group UserDefaults for persistence.
    func updateToUserDefaults() {
        let userDefaults = UserDefaults(suiteName: "group.MomCare")
        if let user, let userDefaults, let data = try? PropertyListEncoder().encode(user) {
            userDefaults.set(data, forKey: "user")
        }
    }

    /// Fetches the current user from UserDefaults.
    ///
    /// - Parameter updateToDatabase: If true, sets the fetched user to `self.user`.
    /// - Returns: The decoded `User` object or `nil` if not found.
    @MainActor
    func fetchFromUserDefaults(updateToDatabase: Bool = false) -> User? {
        if let data = UserDefaults(suiteName: "group.MomCare")?.value(forKey: "user") as? Data {
            let user: User? = try? PropertyListDecoder().decode(User.self, from: data)

            if updateToDatabase {
                self.user = user
            }

            return user
        }

        return user
    }

    /// Updates the current user to the database asynchronously using a private queue.
    func updateToDatabase() {
        queue.async {
            Task {
                await self.updateUser(self.user)
            }
        }
    }

    /// Schedules a timer to refresh the access token before it expires.
    /// If the token has already expired, refreshes immediately.
    func scheduleRefresh() {
        refreshTimer?.invalidate()

        guard let expiryDate = accessTokenExpiresAt else { return }

        let timeInterval = expiryDate.timeIntervalSinceNow - 10 // Refresh 10 seconds before expiry
        guard timeInterval > 0 else {
            Task { await refreshToken() }
            return
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            Task { await self.refreshToken() }
        }
    }

    /// Adds a food item to a specific meal type.
    ///
    /// - Parameters:
    ///   - foodItem: The food item to add.
    ///   - meal: The meal type (breakfast, lunch, snacks, dinner).
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

    /// Removes a food item from a specific meal type.
    ///
    /// - Parameters:
    ///   - foodItem: The food item to remove.
    ///   - meal: The meal type (breakfast, lunch, snacks, dinner).
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

    /// Toggles the `consumed` status of a food item in a specific meal.
    ///
    /// - Parameters:
    ///   - foodItem: The food item to toggle.
    ///   - meal: The meal type.
    /// - Returns: The updated consumed state or `false` if the item was not found.
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

    /// Marks all food items in a meal as consumed or not consumed.
    ///
    /// - Parameters:
    ///   - meal: The meal type.
    ///   - consumed: The desired consumed state (default: true).
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

    // MARK: Private

    /// Timer used to schedule token refreshes before expiration.
    private var refreshTimer: Timer?

}
