//
//  HealthKitHandler+Reader.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import OSLog
import HealthKit

/// Logger for HealthKit read operations
private let logger: Logger = .init(subsystem: "com.MomCare.HealthKit", category: "HealthKit")

/// Extension to `HealthKitHandler` providing convenience methods for reading
/// common health metrics such as steps, calories, macronutrients, and workouts.
extension HealthKitHandler {

    /// Reads the user's step count for today.
    ///
    /// - Parameter completionHandler: Closure called with the total step count as `Double`.
    func readStepCount(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count()) {
            completionHandler($0)
        }
    }

    /// Reads the user's active calories burned for today.
    ///
    /// - Parameter completionHandler: Closure called with the calories burned as `Double`.
    func readCaloriesBurned(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .activeEnergyBurned, unit: .kilocalorie()) {
            completionHandler($0)
        }
    }

    /// Reads the user's dietary calories intake for today.
    ///
    /// - Parameter completionHandler: Closure called with the calories consumed as `Double`.
    func readCaloriesIntake(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryEnergyConsumed, unit: .kilocalorie()) {
            completionHandler($0)
        }
    }

    /// Reads the user's total fat intake for today.
    ///
    /// - Parameter completionHandler: Closure called with total fat in grams as `Double`.
    func readTotalFat(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryFatTotal, unit: .gram()) {
            completionHandler($0)
        }
    }

    /// Reads the user's total protein intake for today.
    ///
    /// - Parameter completionHandler: Closure called with total protein in grams as `Double`.
    func readTotalProtein(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryProtein, unit: .gram()) {
            completionHandler($0)
        }
    }

    /// Reads the user's total carbohydrate intake for today.
    ///
    /// - Parameter completionHandler: Closure called with total carbohydrates in grams as `Double`.
    func readTotalCarbs(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryCarbohydrates, unit: .gram()) {
            completionHandler($0)
        }
    }

    /// Reads the user's workout duration for the past day.
    ///
    /// - Parameter completionHandler: Closure called with total workout duration in minutes as `Double`.
    /// - Note: This method sums up all workouts recorded in HealthKit for the past day.
    func readWorkout(completionHandler: @escaping @Sendable (Double) -> Void) {
        let workoutType = HKWorkoutType.workoutType()
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            if let error {
                logger.error("Workout query failed: \(error.localizedDescription)")
            }

            // Sum all workout durations and convert seconds to minutes
            let totalMinutes = (samples as? [HKWorkout])?.reduce(0) { $0 + ($1.duration / 60) } ?? 0
            completionHandler(totalMinutes)
        }

        healthStore.execute(query)
    }
}
