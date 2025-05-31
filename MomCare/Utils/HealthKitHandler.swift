//
//  HealthKitHandler.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/05/25.
//

import OSLog
import HealthKit

private let logger: Logger = .init(subsystem: "com.MomCare.HealthKit", category: "Framework")

class HealthKitHandler {

    // MARK: Public

    @MainActor static let shared: HealthKitHandler = .init()

    // MARK: Internal

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

        try? await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)

        logger.info("HealthKit access granted for read: \(readIdentifiers) and write: \(writeIdentifiers)")
        completionHandler?()
    }

    func readStepCount(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .stepCount, unit: .count(), completionHandler: completionHandler)
    }

    func readCaloriesBurned(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .activeEnergyBurned, unit: .kilocalorie(), completionHandler: completionHandler)
    }

    func readCaloriesIntake(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryEnergyConsumed, unit: .kilocalorie(), completionHandler: completionHandler)
    }

    func readTotalFat(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryFatTotal, unit: .gram(), completionHandler: completionHandler)
    }

    func readTotalProtein(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryProtein, unit: .gram(), completionHandler: completionHandler)
    }

    func readTotalCarbs(completionHandler: @escaping @Sendable (Double) -> Void) {
        fetchHealthData(quantityTypeIdentifier: .dietaryCarbohydrates, unit: .gram(), completionHandler: completionHandler)
    }

    func readWorkout(completionHandler: @escaping @Sendable (Double) -> Void) {
        let workoutType = HKWorkoutType.workoutType()
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            let totalMinutes = (samples as? [HKWorkout])?.reduce(0) { $0 + ($1.duration / 60) } ?? 0
            completionHandler(totalMinutes)
        }

        healthStore.execute(query)
    }

    // MARK: Private

    private func fetchHealthData(quantityTypeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, completionHandler: @escaping @Sendable (Double) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier) else { return }

        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            completionHandler(value)
        }

        healthStore.execute(query)
    }

}
