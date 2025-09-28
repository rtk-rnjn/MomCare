//
//  HealthKitHandler+Async.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import HealthKit

/// Extension to `HealthKitHandler` providing async/await versions of common
/// health data reading methods. These allow calling HealthKit methods
/// with Swift concurrency, removing the need for completion handlers.
extension HealthKitHandler {

    // MARK: - Steps

    /// Reads the user's step count for today asynchronously.
    ///
    /// - Returns: Total steps as `Double`.
    /// - Note: This method wraps the completion-handler version using `withCheckedContinuation`.
    func readStepCount() async -> Double {
        await withCheckedContinuation { continuation in
            readStepCount { stepCount in
                continuation.resume(returning: stepCount)
            }
        }
    }

    // MARK: - Workouts

    /// Reads the user's workout duration for the past day asynchronously.
    ///
    /// - Returns: Total workout duration in minutes as `Double`.
    func readWorkout() async -> Double {
        await withCheckedContinuation { continuation in
            readWorkout { totalMinutes in
                continuation.resume(returning: totalMinutes)
            }
        }
    }

    // MARK: - Calories

    /// Reads the user's active calories burned asynchronously.
    ///
    /// - Returns: Calories burned as `Double`.
    func readCaloriesBurned() async -> Double {
        await withCheckedContinuation { continuation in
            readCaloriesBurned { caloriesBurned in
                continuation.resume(returning: caloriesBurned)
            }
        }
    }

    /// Reads the user's dietary calories intake asynchronously.
    ///
    /// - Returns: Calories consumed as `Double`.
    func readCaloriesIntake() async -> Double {
        await withCheckedContinuation { continuation in
            readCaloriesIntake { caloriesIntake in
                continuation.resume(returning: caloriesIntake)
            }
        }
    }

    // MARK: - Macronutrients

    /// Reads the user's total fat intake asynchronously.
    ///
    /// - Returns: Total fat in grams as `Double`.
    func readTotalFat() async -> Double {
        await withCheckedContinuation { continuation in
            readTotalFat { totalFat in
                continuation.resume(returning: totalFat)
            }
        }
    }

    /// Reads the user's total protein intake asynchronously.
    ///
    /// - Returns: Total protein in grams as `Double`.
    func readTotalProtein() async -> Double {
        await withCheckedContinuation { continuation in
            readTotalProtein { totalProtein in
                continuation.resume(returning: totalProtein)
            }
        }
    }

    /// Reads the user's total carbohydrate intake asynchronously.
    ///
    /// - Returns: Total carbohydrates in grams as `Double`.
    func readTotalCarbs() async -> Double {
        await withCheckedContinuation { continuation in
            readTotalCarbs { totalCarbs in
                continuation.resume(returning: totalCarbs)
            }
        }
    }

    // MARK: - Generic fetch

    /// Fetches health data for any quantity type asynchronously.
    ///
    /// - Parameters:
    ///   - quantityTypeIdentifier: The HealthKit quantity type identifier (e.g., `.stepCount`).
    ///   - unit: Unit to convert the value into (e.g., `.count()`, `.kilocalorie()`).
    /// - Returns: The fetched value as `Double`.
    ///
    /// - Note: This wraps `fetchHealthData(quantityTypeIdentifier:unit:completionHandler:)` in an async context.
    func fetchHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        unit: HKUnit
    ) async -> Double {
        await withCheckedContinuation { continuation in
            fetchHealthData(quantityTypeIdentifier: quantityTypeIdentifier, unit: unit) { value in
                continuation.resume(returning: value)
            }
        }
    }
}
