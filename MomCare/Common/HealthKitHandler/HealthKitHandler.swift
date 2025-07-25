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

    func fetchHealthData(quantityTypeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, completionHandler: @escaping @Sendable (Double) -> Void) {
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

    func writeHealthData(quantityTypeIdentifier: HKQuantityTypeIdentifier, value: Double, unit: HKUnit, start: Date = .init(), end: Date = .init(), completionHandler: @escaping @Sendable (Bool) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            logger.error("Invalid quantity type for identifier: \(quantityTypeIdentifier.rawValue)")
            completionHandler(false)
            return
        }

        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)

        healthStore.save(sample) { success, error in
            if let error {
                logger.error("Failed to save health data for \(quantityTypeIdentifier.rawValue): \(error.localizedDescription)")
            }
            completionHandler(success)
        }
    }
}
