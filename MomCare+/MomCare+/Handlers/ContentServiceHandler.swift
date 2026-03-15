import Combine
import HealthKit
import SwiftUI
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.ContentServiceHandler", category: "ObservableObject")

final class ContentServiceHandler: ObservableObject {

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

    @Published var totalUserExercisesDuration: Double = 0
    @Published var totalUserExercisesCompletionDuration: Double = 0

    @Published var totalUserExercisesCompleted: Int = 0

    @Published var weeklyProgress: [DayProgress] = .init()

    @Published var minutes: Double = 0
    @Published var caloriesBurned: Int = 0

    @Published var todayFocusText: String = ""
    @Published var dailyTipText: String = ""

    let healthStore: HKHealthStore = .init()

    nonisolated func startStepCountObservation() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            fatalError()
        }
        let now = Date()
        let startOfDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDate, end: now, options: .strictStartDate)

        let query = HKObserverQuery(sampleType: stepType, predicate: predicate) { _, _, error in
            if error != nil {
                return
            }

            self.fetchTodaySteps()
        }
        healthStore.execute(query)
        try? await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)

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

    func fetchTotalUserExercisesDuration() async {
        totalUserExercisesDuration = 0

        for userExercise in userExercises {
            let exercise = await userExercise.exerciseModel
            totalUserExercisesDuration += exercise?.videoDurationSeconds ?? 0
        }
    }

    func fetchTotalUserExercisesCompletionDuration() async {
        totalUserExercisesCompletionDuration = 0

        for userExercise in userExercises {
            totalUserExercisesCompletionDuration += userExercise.videoDurationCompletedSeconds
        }
    }

    func fetchTotalUserExercisesCompleted() async {
        totalUserExercisesCompleted = 0

        for userExercise in userExercises {
            if await userExercise.isCompleted {
                totalUserExercisesCompleted += 1
            }
        }
    }

    func fetchMealPlan(makeNetworkCall: Bool = true) async throws {
        if makeNetworkCall {
            let networkResponse = try await ContentService.shared.generateMealPlan()

            myPlanModel = networkResponse.data
        }

        let nurtitionConsumedTotals = await myPlanModel?.consumedNutrition()
        let nutritionTargetTotals = await myPlanModel?.targetNutrition()

        await MainActor.run {
            self.nutritionTargetTotals = nutritionTargetTotals
            self.nurtitionConsumedTotals = nurtitionConsumedTotals
        }
    }

    nonisolated func fetchHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        startDate: Date = Calendar.current.startOfDay(for: Date()),
        endDate: Date = .init(),
        completionHandler: @escaping @Sendable (Double) -> Void
    ) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

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

    nonisolated func writeHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        value: Double,
        unit: HKUnit,
    ) async throws {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            return
        }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)

        try await healthStore.save(sample)
    }

    nonisolated func fetchTodaySteps() {
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

extension ContentServiceHandler {
    func consumeFoodInHealthKit(_ food: FoodItemModel, consume: Bool) async throws {
        let multiplier = consume ? 1.0 : -1.0

        try await writeHealthData(quantityTypeIdentifier: .dietaryEnergyConsumed, value: food.totalCalories * multiplier, unit: .kilocalorie())
        try await writeHealthData(quantityTypeIdentifier: .dietaryProtein, value: food.totalProteinInGrams * multiplier, unit: .gram())
        try await writeHealthData(quantityTypeIdentifier: .dietaryCarbohydrates, value: food.totalCarbsInGrams * multiplier, unit: .gram())
        try await writeHealthData(quantityTypeIdentifier: .dietaryFatTotal, value: food.totalFatsInGrams * multiplier, unit: .gram())
        try await writeHealthData(quantityTypeIdentifier: .dietarySodium, value: food.totalSodiumInMiligrams * multiplier, unit: .gramUnit(with: .milli))
        try await writeHealthData(quantityTypeIdentifier: .dietarySugar, value: food.totalSugarInGrams * multiplier, unit: .gram())
    }

    func markFoodAs(consumed: Bool, in mealType: MealType, foodReference: FoodReferenceModel) async throws {
        guard let myPlanModel else {
            return
        }

        guard foodReference.isConsumed != consumed else {
            return
        }
        if let index = self.myPlanModel?[mealType].firstIndex(where: { $0.foodId == foodReference.foodId }) {
            self.myPlanModel?[mealType][index].toggleConsume()
        }

        _ = try await ContentService.shared.markFoodAs(consumed: consumed, planId: myPlanModel._id, meal: mealType, foodId: foodReference.foodId)
        if let food = await foodReference.food {
            try await consumeFoodInHealthKit(food, consume: consumed)
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

extension ContentServiceHandler {
    func updateExerciseCompletionDuration(id: String, duration: TimeInterval) async throws {
        let networkResponse = try await ContentService.shared.updateExerciseCompletion(userExerciseId: id, duration: duration)
        if let success = networkResponse.data, success {
            if let index = userExercises.firstIndex(where: { $0.exerciseId == id }) {
                await MainActor.run {
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
        breathingCompletionDuration = duration
    }
}

extension ContentServiceHandler {
    func fetchBreathingCompletionDuration(for date: Date) -> TimeInterval {
        if date > Date() {
            return 0
        }

        let startOfDate = Calendar.current.startOfDay(for: date)
        let completionDuration: TimeInterval = database[.breathing(startOfDate)] ?? 0
        breathingCompletionDuration = completionDuration
        return completionDuration
    }

    func fetchUserExercises(for date: Date) async throws -> [UserExerciseModel]? {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        if date > Date() {
            return nil
        }

        if let userExercises = ContentService.shared.findUserExercises(on: date) {
            return userExercises
        }

        let networkResponse = try await ContentService.shared.fetchUserExercises(from: startDate, to: endDate)
        return networkResponse.data
    }

    func fetchStepCount(for date: Date) async -> Int {
        if date > Date() {
            return 0
        }

        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        return await withCheckedContinuation { continuation in
            fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count(), startDate: startDate, endDate: endDate) { count in
                continuation.resume(returning: Int(count))
            }
        }
    }

    func calculateTotalCompletionPercentage(for date: Date) async -> Double {
        let exercises = try? await fetchUserExercises(for: date)
        guard let exercises else { return 0 }

        var totalDuration: Double = 0
        var totalCompletedDuration: Double = 0

        for exercise in exercises {
            if let exerciseModel = await exercise.exerciseModel {
                totalDuration += exerciseModel.videoDurationSeconds
                totalCompletedDuration += exercise.videoDurationCompletedSeconds
            }
        }

        guard totalDuration > 0 else { return 0 }

        return min(totalCompletedDuration / totalDuration, 1.0)
    }

    func fetchWeeklyProgress() async {
        let range = Utils.weekRange(containing: Date())
        var temp = [DayProgress]()

        for date in range {
            let exerciseProgressPercentage: Double = await calculateTotalCompletionPercentage(for: date)
            let breathingProgressPercentage: Double = fetchBreathingCompletionDuration(for: date) / breathingTargetInSeconds

            let progress = (exerciseProgressPercentage + breathingProgressPercentage) / 2
            temp.append(.init(date: date, completionPercentage: progress))
        }
        weeklyProgress = temp
    }

    func updateWeeklyProgressForToday() async {
        let now = Date()

        let exerciseProgressPercentage: Double = await calculateTotalCompletionPercentage(for: now)
        let breathingProgressPercentage: Double = fetchBreathingCompletionDuration(for: now) / breathingTargetInSeconds

        let progress = (exerciseProgressPercentage + breathingProgressPercentage) / 2

        if let index = weeklyProgress.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: now) }) {
            weeklyProgress[index].completionPercentage = progress
        }
    }
}
