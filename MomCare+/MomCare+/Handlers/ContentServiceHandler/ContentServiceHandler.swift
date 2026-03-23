import Combine
import HealthKit
import OSLog
import SwiftUI

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
}
