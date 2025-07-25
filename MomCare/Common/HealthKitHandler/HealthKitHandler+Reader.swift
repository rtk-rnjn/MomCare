//
//  HealthKitHandler+Reader.swift
//  MomCare
//
//  Created by Ritik Ranjan on 25/07/25.
//

import OSLog
import HealthKit

private let logger: Logger = .init(subsystem: "com.MomCare.HealthKit", category: "Framework")

extension HealthKitHandler {
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
}
