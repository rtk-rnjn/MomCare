//
//  HealthKitHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/05/25.
//

import OSLog
import HealthKit

/// Logger for HealthKitHandler related events
private let logger: Logger = .init(subsystem: "com.MomCare.HealthKit", category: "HealthKit")

/// `HealthKitHandler` is a thread-safe singleton actor responsible for
/// managing HealthKit authorization, reading, and writing health data.
/// It handles common health metrics such as steps, calories, exercise time,
/// and macronutrients.
actor HealthKitHandler {

    /// Shared singleton instance
    static let shared: HealthKitHandler = .init()

    /// The underlying HealthKit store
    let healthStore: HKHealthStore = .init()

    /// Requests access to read and write selected HealthKit data types.
    ///
    /// - Parameter completionHandler: Optional closure called after authorization attempt completes.
    /// - Note: This uses `async` because HealthKit's requestAuthorization method is asynchronous.
    func requestAccess(completionHandler: (() -> Void)? = nil) async {
        // Health data types to read
        let readIdentifiers: [HKQuantityTypeIdentifier] = [
            .activeEnergyBurned, .stepCount, .appleExerciseTime,
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal
        ]

        // Health data types to write
        let writeIdentifiers: [HKQuantityTypeIdentifier] = [
            .dietaryEnergyConsumed, .dietaryProtein, .dietaryCarbohydrates, .dietaryFatTotal
        ]

        // Convert identifiers to HKQuantityType objects
        let readTypes = Set(readIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) })
        let writeTypes = Set(writeIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0) })

        do {
            try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        } catch {
            logger.error("HealthKit authorization failed: \(error.localizedDescription)")
        }

        completionHandler?()
    }

    /// Fetches cumulative health data for today for the given quantity type.
    ///
    /// - Parameters:
    ///   - quantityTypeIdentifier: The HealthKit quantity type identifier (e.g., `.stepCount`).
    ///   - unit: The unit to convert the data into (e.g., `HKUnit.count()` or `HKUnit.kilocalorie()`).
    ///   - completionHandler: Closure called with the fetched value. Executed on the thread HealthKit calls back on.
    ///
    /// - Note: HealthKit executes queries on background threads. If updating UI, wrap the completionHandler in `DispatchQueue.main.async`.
    func fetchHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        completionHandler: @escaping @Sendable (Double) -> Void
    ) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            logger.error("Invalid quantity type for identifier: \(quantityTypeIdentifier.rawValue)")
            return
        }

        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            if let error {
                logger.error("Health data query for \(quantityTypeIdentifier.rawValue) failed: \(error.localizedDescription)")
            }
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            logger.debug("Fetched \(quantityTypeIdentifier.rawValue): \(value)")
            completionHandler(value)
        }

        healthStore.execute(query)
    }

    /// Writes health data to HealthKit.
    ///
    /// - Parameters:
    ///   - quantityTypeIdentifier: The HealthKit quantity type identifier to write.
    ///   - value: The value to write.
    ///   - unit: The unit of the value.
    ///   - start: Start date of the sample. Defaults to current date.
    ///   - end: End date of the sample. Defaults to current date.
    ///   - completionHandler: Closure called with a `Bool` indicating success.
    ///
    /// - Note: For cumulative metrics (like steps or calories), ensure `start` and `end` reflect the measurement period.
    func writeHealthData(
        quantityTypeIdentifier: HKQuantityTypeIdentifier,
        value: Double,
        unit: HKUnit,
        start: Date = .init(),
        end: Date = .init(),
        completionHandler: @escaping @Sendable (Bool) -> Void
    ) {
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
