//
//  HealthKitHandler+Async.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import HealthKit

extension HealthKitHandler {
    func readStepCount() async -> Double {
        await withCheckedContinuation { continuation in
            readStepCount { stepCount in
                continuation.resume(returning: stepCount)
            }
        }
    }

    func readWorkout() async -> Double {
        await withCheckedContinuation { continuation in
            readWorkout { totalMinutes in
                continuation.resume(returning: totalMinutes)
            }
        }
    }

    func readCaloriesBurned() async -> Double {
        await withCheckedContinuation { continuation in
            readCaloriesBurned { caloriesBurned in
                continuation.resume(returning: caloriesBurned)
            }
        }
    }

    func readCaloriesIntake() async -> Double {
        await withCheckedContinuation { continuation in
            readCaloriesIntake { caloriesIntake in
                continuation.resume(returning: caloriesIntake)
            }
        }
    }

    func readTotalFat() async -> Double {
        await withCheckedContinuation { continuation in
            readTotalFat { totalFat in
                continuation.resume(returning: totalFat)
            }
        }
    }

    func readTotalProtein() async -> Double {
        await withCheckedContinuation { continuation in
            readTotalProtein { totalProtein in
                continuation.resume(returning: totalProtein)
            }
        }
    }

    func readTotalCarbs() async -> Double {
        await withCheckedContinuation { continuation in
            readTotalCarbs { totalCarbs in
                continuation.resume(returning: totalCarbs)
            }
        }
    }

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
