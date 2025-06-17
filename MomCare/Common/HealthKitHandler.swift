//
//  HealthKitHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/05/25.
//

import OSLog
import HealthKit

private let logger: Logger = .init(subsystem: "com.MomCare.HealthKit", category: "Framework")

actor HealthKitHandler {

    // MARK: Internal

    static let shared: HealthKitHandler = .init()

    let healthStore: HKHealthStore = .init()

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

        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        } catch {
            logger.error("HealthKit authorization failed: \(error.localizedDescription)")
        }

        completionHandler?()
    }

    func readStepCount(completionHandler: @escaping @Sendable (Double) -> Void) {
        logger.debug("Reading step count...")
        fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count(), completionHandler: {
            logger.debug("Step count fetched: \($0)")
            completionHandler($0)
        })
    }

    func readCaloriesBurned(completionHandler: @escaping @Sendable (Double) -> Void) {
        logger.debug("Reading calories burned...")
        fetchHealthData(quantityTypeIdentifier: .activeEnergyBurned, unit: .kilocalorie(), completionHandler: {
            logger.debug("Calories burned fetched: \($0)")
            completionHandler($0)
        })
    }

    func readCaloriesIntake(completionHandler: @escaping @Sendable (Double) -> Void) {
        logger.debug("Reading calories intake...")
        fetchHealthData(quantityTypeIdentifier: .dietaryEnergyConsumed, unit: .kilocalorie(), completionHandler: {
            logger.debug("Calories intake fetched: \($0)")
            completionHandler($0)
        })
    }

    func readTotalFat(completionHandler: @escaping @Sendable (Double) -> Void) {
        logger.debug("Reading total fat...")
        fetchHealthData(quantityTypeIdentifier: .dietaryFatTotal, unit: .gram(), completionHandler: {
            logger.debug("Total fat fetched: \($0)")
            completionHandler($0)
        })
    }

    func readTotalProtein(completionHandler: @escaping @Sendable (Double) -> Void) {
        logger.debug("Reading total protein...")
        fetchHealthData(quantityTypeIdentifier: .dietaryProtein, unit: .gram(), completionHandler: {
            logger.debug("Total protein fetched: \($0)")
            completionHandler($0)
        })
    }

    func readTotalCarbs(completionHandler: @escaping @Sendable (Double) -> Void) {
        logger.debug("Reading total carbs...")
        fetchHealthData(quantityTypeIdentifier: .dietaryCarbohydrates, unit: .gram(), completionHandler: {
            logger.debug("Total carbohydrates fetched: \($0)")
            completionHandler($0)
        })
    }

    func readWorkout(completionHandler: @escaping @Sendable (Double) -> Void) {
        logger.debug("Reading workout data...")
        let workoutType = HKWorkoutType.workoutType()
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            if let error {
                logger.error("Workout query failed: \(error.localizedDescription)")
            }
            let totalMinutes = (samples as? [HKWorkout])?.reduce(0) { $0 + ($1.duration / 60) } ?? 0
            logger.debug("Workout duration fetched: \(totalMinutes) minutes")
            completionHandler(totalMinutes)
        }

        healthStore.execute(query)
    }

    // MARK: Private

    private func fetchHealthData(quantityTypeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, completionHandler: @escaping @Sendable (Double) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            logger.error("Invalid quantity type for identifier: \(quantityTypeIdentifier.rawValue)")
            return
        }

        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error {
                logger.error("Health data query for \(quantityTypeIdentifier.rawValue) failed: \(error.localizedDescription)")
            }
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            logger.debug("Fetched \(quantityTypeIdentifier.rawValue): \(value)")
            completionHandler(value)
        }

        healthStore.execute(query)
    }
}

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
