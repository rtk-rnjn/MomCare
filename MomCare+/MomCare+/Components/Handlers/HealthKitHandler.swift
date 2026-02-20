import Combine
import HealthKit
import SwiftUI

final class HealthKitHandler: ObservableObject {

    // MARK: Internal

    @Published var myPlanModel: MyPlanModel?
    @Published var userExercises: [UserExerciseModel] = []

    @Published var currentSteps: Double = 0
    @Published var targetSteps: Double = 4200
    @Published var stepsProgress: Double = 0

    @Published var breathingTargetInSeconds: Double = 300
    @Published var breathingCompletionDuration: Double = 0

    @Published var nurtitionConsumedTotals: NutritionTotals?
    @Published var nutritionTargetTotals: NutritionTotals?

    @Published var totalExerciseDuration: Double = 0

    @Published var minutes: Double = 0
    @Published var caloriesBurned: Int = 0

    @Published var todayFocusText: String = "Loading todays focus from our server ..."
    @Published var dailyTipText: String = "Loading today's tip from our server ..."

    let healthStore: HKHealthStore = .init()

    func startStepCountObservation() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            fatalError()
        }
        let now = Date()
        let startOfDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDate, end: now, options: .strictStartDate)

        let query = HKObserverQuery(sampleType: stepType, predicate: predicate) { _, _, _ in
            Task {
                await self.fetchTodaySteps()
            }
        }
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { _, _ in }

        fetchTodaySteps()
    }

    func requestAccess(completionHandler: (() -> Void)? = nil) async {
        let readIdentifiers: [HKQuantityTypeIdentifier] = [
            .activeEnergyBurned, .stepCount, .appleExerciseTime,
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal
        ]

        let writeIdentifiers: [HKQuantityTypeIdentifier] = [
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal
        ]

        let readTypes = Set(readIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) })
        let writeTypes = Set(writeIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) })

        try? await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)

        completionHandler?()
    }

    func fetchTotalDuration() async {
        for userExercise in userExercises {
            let exercise = await userExercise.exerciseModel
            totalExerciseDuration += exercise?.videoDurationSeconds ?? 0
        }
    }

    func fetchMealPlan(makeNetworkCall: Bool = true) async throws {
        if makeNetworkCall {
            let networkResponse = try await ContentService.shared.fetchMealPlan()

            myPlanModel = networkResponse.data
        }

        let nurtitionConsumedTotals = await myPlanModel?.consumedNutrition()
        let nutritionTargetTotals = await myPlanModel?.targetNutrition()

        DispatchQueue.main.async {
            self.nutritionTargetTotals = nutritionTargetTotals
            self.nurtitionConsumedTotals = nurtitionConsumedTotals
        }
    }

    func fetchHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        completionHandler: @escaping @Sendable (Double) -> Void
    ) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            return
        }

        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            completionHandler(value)
        }

        healthStore.execute(query)
    }

    func writeHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        value: Double,
        unit: HKUnit,
        completionHandler: (@Sendable (Bool) -> Void)? = nil
    ) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            completionHandler?(false)
            return
        }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)

        healthStore.save(sample) { success, _ in
            completionHandler?(success)
        }
    }

    func fetchTodaySteps() {
        fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count()) { count in
            DispatchQueue.main.async {
                self.currentSteps = count
                self.stepsProgress = min(count / self.targetSteps, 0.9999)
            }
        }
    }

    // MARK: Private

    private let database: Database = .init()

}

extension HealthKitHandler {
    func consumeFoodInHealthKit(_ food: FoodItemModel, consume: Bool) {
        let multiplier = consume ? 1.0 : -1.0
        writeHealthData(quantityTypeIdentifier: .dietaryEnergyConsumed, value: food.totalCalories * multiplier, unit: .kilocalorie())
        writeHealthData(quantityTypeIdentifier: .dietaryProtein, value: food.totalProteinInGrams * multiplier, unit: .gram())
        writeHealthData(quantityTypeIdentifier: .dietaryCarbohydrates, value: food.totalCarbsInGrams * multiplier, unit: .gram())
        writeHealthData(quantityTypeIdentifier: .dietaryFatTotal, value: food.totalFatsInGrams * multiplier, unit: .gram())
        writeHealthData(quantityTypeIdentifier: .dietarySodium, value: food.totalSodiumInMiligrams * multiplier, unit: .gramUnit(with: .milli))
        writeHealthData(quantityTypeIdentifier: .dietarySugar, value: food.totalSugarInGrams * multiplier, unit: .gram())
    }

    func markFoodAs(consumed: Bool, in mealType: MealType, foodReference: FoodReferenceModel) async throws {
        guard let myPlanModel else { return }

        if foodReference.isConsumed == consumed { return }

        switch mealType {
        case .breakfast:
            if let index = self.myPlanModel?.breakfast.firstIndex(where: { $0.foodId == foodReference.foodId }) {
                self.myPlanModel?.breakfast[index].toggleConsume()
            }

        case .lunch:
            if let index = self.myPlanModel?.lunch.firstIndex(where: { $0.foodId == foodReference.foodId }) {
                self.myPlanModel?.lunch[index].toggleConsume()
            }

        case .dinner:
            if let index = self.myPlanModel?.dinner.firstIndex(where: { $0.foodId == foodReference.foodId }) {
                self.myPlanModel?.dinner[index].toggleConsume()
            }

        case .snacks:
            if let index = self.myPlanModel?.snacks.firstIndex(where: { $0.foodId == foodReference.foodId }) {
                self.myPlanModel?.snacks[index].toggleConsume()
            }
        }

        _ = try await ContentService.shared.markFoodAs(consumed: consumed, planId: myPlanModel._id, meal: mealType, foodId: foodReference.foodId)
        if let food = await foodReference.food {
            consumeFoodInHealthKit(food, consume: consumed)
        }
    }

    func markFoodsAs(consumed: Bool, mealType: MealType) async throws {
        switch mealType {
        case .breakfast:
            for foodReference in myPlanModel?.breakfast ?? [] {
                try await markFoodAs(consumed: consumed, in: mealType, foodReference: foodReference)
            }

        case .lunch:
            for foodReference in myPlanModel?.lunch ?? [] {
                try await markFoodAs(consumed: consumed, in: mealType, foodReference: foodReference)
            }

        case .dinner:
            for foodReference in myPlanModel?.dinner ?? [] {
                try await markFoodAs(consumed: consumed, in: mealType, foodReference: foodReference)
            }

        case .snacks:
            for foodReference in myPlanModel?.snacks ?? [] {
                try await markFoodAs(consumed: consumed, in: mealType, foodReference: foodReference)
            }
        }
    }

    func addFoodToMyPlan(foodId: String, mealType: MealType) async throws {
        guard let myPlanModel else { return }

        _ = try await ContentService.shared.addFoodItem(toPlan: myPlanModel._id, meal: mealType, foodId: foodId)

        try await fetchMealPlan()
    }

    func removeFoodFromPlan(foodId: String, mealType: MealType) async throws {
        guard let myPlanModel else { return }

        _ = try await ContentService.shared.removeFoodItem(fromPlan: myPlanModel._id, meal: mealType, foodId: foodId)

        try await fetchMealPlan()
    }
}

extension HealthKitHandler {
    func updateExerciseCompletionDuration(id: String, duration: TimeInterval) async throws {
        let networkResponse = try await ContentService.shared.updateExerciseCompletion(exerciseId: id, duration: duration)
        if let success = networkResponse.data, success {
            if let index = userExercises.firstIndex(where: { $0.exerciseId == id }) {
                DispatchQueue.main.async {
                    self.userExercises[index].videoDurationCompletedSeconds = duration
                }
            }
        }
    }

    func fetchExerciseCompletionDuration(id: String) -> TimeInterval {
        if let index = userExercises.firstIndex(where: { $0.id == id }) {
            return userExercises[index].videoDurationCompletedSeconds
        }

        return 0
    }

    func updateBreathingCompletionDuration(duration: TimeInterval) {
        let now = Date()
        let startOfDate = Calendar.current.startOfDay(for: now)
        database[.breathing(startOfDate)] = duration
        DispatchQueue.main.async {
            self.breathingCompletionDuration = duration
        }
    }

    func fetchBreathingCompletionDuration(for date: Date) -> TimeInterval {
        let startOfDate = Calendar.current.startOfDay(for: date)
        let completionDuration: TimeInterval = database[.breathing(startOfDate)] ?? 0
        DispatchQueue.main.async {
            self.breathingCompletionDuration = completionDuration
        }
        return completionDuration
    }
}
