import Combine
import HealthKit
import SwiftUI
import OSLog

struct StepDataPoint: Identifiable {
    let id: UUID = .init()
    let date: Date
    let steps: Int

    var shortLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        return fmt.string(from: date)
    }

}

final class ContentServiceHandler: ObservableObject {

    // MARK: Lifecycle

    init() {
        let startOfTheDate = Calendar.current.startOfDay(for: .init())

        myPlanModel = Database.shared[.mealPlan(startOfTheDate)]

        if let userExercises: [UserExerciseModel] = Database.shared[.userExercises(startOfTheDate)] {
            self.userExercises = userExercises
        }

        if myPlanModel != nil {
            Task {
                await fetchMyPlanMeta()
            }
        }
    }

    // MARK: Internal

    @Published var isFetchingMealPlan: Bool = false
    @Published var isFetchingExercises: Bool = false

    @Published var stepsToday: Double = 0
    @Published var stepsGoal: Double = 4200

    @Published var breathingTargetInSeconds: Double = 300
    @Published var breathingCompletionDuration: Double = 0

    @Published var nutritionIntakeTotals: NutritionTotals?
    @Published var nutritionGoalTotals: NutritionTotals?
    @Published var recommendedNutritionGoalTotals: NutritionTotals?

    @Published var totalUserExercisesCompleted: Int = 0
    @Published var totalExerciseDuration: TimeInterval = 0

    @Published var weeklyProgress: [DayProgress] = .init()

    @Published var caloriesBurned: Int = 0

    @Published var todayFocusText: String = ""
    @Published var dailyTipText: String = ""

    let healthStore: HKHealthStore = .init()

    @Published var myPlanModel: MealPlanModel? {
        didSet {
            if let myPlanModel {
                let startOfTheDate = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: myPlanModel.createdAtTimestamp))
                Database.shared[.mealPlan(startOfTheDate)] = myPlanModel
            }
        }
    }

    @Published var userExercises: [UserExerciseModel] = [] {
        didSet {
            if !userExercises.isEmpty {
                let startOfTheDate = Calendar.current.startOfDay(for: .init())
                Database.shared[.userExercises(startOfTheDate)] = userExercises
            }
        }
    }

    nonisolated func startStepCountObservation() async throws {
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
        try await healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate)

        fetchTodaySteps()
    }

    func requestHealthKitAccess() async throws -> [HKQuantityTypeIdentifier: HKAuthorizationStatus] {

        let readIdentifiers: [HKQuantityTypeIdentifier] = [
            .activeEnergyBurned, .stepCount, .appleExerciseTime, .height, .bodyMass, .dietaryWater,
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal, .dietarySugar, .dietarySodium
        ]

        let writeIdentifiers: [HKQuantityTypeIdentifier] = [
            .height, .bodyMass, .dietaryWater,
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal, .dietarySugar, .dietarySodium
        ]

        let readTypes = Set(readIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) })
        let writeTypes = Set(writeIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) })

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)

        var status = [HKQuantityTypeIdentifier: HKAuthorizationStatus]()
        for identifier in readIdentifiers {
            if let type = HKQuantityType.quantityType(forIdentifier: identifier) {
                status[identifier] = healthStore.authorizationStatus(for: type)
            }
        }
        return status
    }

    func fetchUserExercises() async throws {

        isFetchingExercises = true
        defer { isFetchingExercises = false }

        let networkResponse = try await ContentRepository.shared.generateUserExercises()
        userExercises = networkResponse.data

        await fetchUserExercisesMeta()
    }

    func fetchUserExercisesMeta() async {
        await fetchWeeklyExerciseProgress()
        totalUserExercisesCompleted = await userExercises.fetchTotalUserExercisesCompleted()
        totalExerciseDuration = await userExercises.fetchTotalExerciseDuration()
    }

    func fetchMyPlanMeta() async {
        let nurtitionConsumedTotals = await myPlanModel?.consumedNutrition()
        let nutritionTargetTotals = await myPlanModel?.targetNutrition(of: .user)
        let originalNutritionTargetTotals = await myPlanModel?.targetNutrition(of: .server)

        nutritionGoalTotals = nutritionTargetTotals
        nutritionIntakeTotals = nurtitionConsumedTotals
        recommendedNutritionGoalTotals = originalNutritionTargetTotals
    }

    func fetchMealPlan() async throws {
        defer { isFetchingMealPlan = false }

        isFetchingMealPlan = true
        let networkResponse = try await ContentRepository.shared.generateMealPlan()

        myPlanModel = networkResponse.data

        await fetchMyPlanMeta()
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
                self.stepsToday = count
            }
        }
    }

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

        if let food = await foodReference.food {
            try await consumeFoodInHealthKit(food, consume: consumed)
        }

        await fetchMyPlanMeta()

        _ = try await ContentRepository.shared.markFoodAs(consumed: consumed, planId: myPlanModel._id, meal: mealType, foodId: foodReference.foodId)
    }

    func markFoodsAs(consumed: Bool, mealType: MealType) async throws {

        for foodReference in myPlanModel?[mealType] ?? [] {
            Task {
                try await markFoodAs(consumed: consumed, in: mealType, foodReference: foodReference)
            }
        }
    }

    func addFoodToMyPlan(foodId: String, mealType: MealType) async throws {
        guard let myPlanModel else { return }

        _ = try await ContentRepository.shared.addFoodItem(toPlan: myPlanModel._id, meal: mealType, foodId: foodId)

        let foodReference = FoodReferenceModel(foodId: foodId, count: 1)
        if let index = self.myPlanModel?[mealType].firstIndex(where: { $0.foodId == foodId }) {
            self.myPlanModel?[mealType][index].count += 1
        } else {
            self.myPlanModel?[mealType].append(foodReference)
        }
    }

    func removeFoodFromPlan(foodId: String, mealType: MealType) async throws {
        guard let myPlanModel else { return }

        _ = try await ContentRepository.shared.removeFoodItem(fromPlan: myPlanModel._id, meal: mealType, foodId: foodId)

        if let index = self.myPlanModel?[mealType].firstIndex(where: { $0.foodId == foodId }) {
            self.myPlanModel?[mealType].remove(at: index)
        }
    }

    func updateExerciseCompletionDuration(id: String, duration: TimeInterval) async throws {

        _ = try await ContentRepository.shared.updateExerciseCompletion(userExerciseId: id, duration: duration)

        if let index = userExercises.firstIndex(where: { $0.id == id }) {
            await MainActor.run {
                self.userExercises[index].videoDurationCompletedSeconds = duration
            }
        }
    }

    func updateBreathingCompletionDuration(duration: TimeInterval) {

        let now = Date()
        let startOfDate = Calendar.current.startOfDay(for: now)
        Database.shared[.breathingProgress(startOfDate)] = duration
        breathingCompletionDuration = duration
    }

    func fetchBreathingCompletionDuration(for date: Date) -> TimeInterval {
        if date > Date() {
            return 0
        }

        let startOfDate = Calendar.current.startOfDay(for: date)
        let completionDuration: TimeInterval = Database.shared[.breathingProgress(startOfDate)] ?? 0
        breathingCompletionDuration = completionDuration
        return completionDuration
    }

    func fetchUserExercises(for date: Date) async throws -> [UserExerciseModel]? {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        if date > Date() {
            return nil
        }

        let networkResponse = try await ContentRepository.shared.fetchUserExercises(from: startDate, to: endDate)
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

    func fetchWeeklyExerciseProgress() async {
        let range = Utils.weekRange(containing: Date())
        var temp = [DayProgress]()

        for date in range {
            let exerciseProgressPercentage: Double = await calculateTotalCompletionPercentage(for: date)
            let breathingProgressPercentage: Double = fetchBreathingCompletionDuration(for: date) / breathingTargetInSeconds
            let stepsProgressPercentage = Double(await fetchStepCount(for: date)) / stepsGoal

            let progress = (exerciseProgressPercentage + breathingProgressPercentage + stepsProgressPercentage) / 3
            temp.append(.init(date: date, completionPercentage: progress))
        }
        weeklyProgress = temp
    }

    func fetchWeeklyStepsProgress(from date: Date = .init()) async -> [StepDataPoint] {
        let range = Utils.weekRange(containing: date)
        var result = [StepDataPoint]()

        for date in range {
            result.append(.init(date: date, steps: await fetchStepCount(for: date)))
        }

        return result
    }
}
