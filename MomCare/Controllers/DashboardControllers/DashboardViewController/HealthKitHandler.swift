//
//  HealthKitHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/02/25.
//

import Foundation
import HealthKit
import HealthKitUI

extension DashboardViewController {
    func addHKActivityRing(to cellView: UIView, withSummary summary: HKActivitySummary? = nil) {
        let summary = HKActivitySummary()

        summary.activeEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 11)
        summary.activeEnergyBurnedGoal = HKQuantity(unit: .kilocalorie(), doubleValue: 21)
        summary.appleExerciseTime = HKQuantity(unit: .minute(), doubleValue: 1)
        summary.appleExerciseTimeGoal = HKQuantity(unit: .minute(), doubleValue: 2)
        summary.appleStandHours = HKQuantity(unit: .count(), doubleValue: 12)
        summary.appleStandHoursGoal = HKQuantity(unit: .count(), doubleValue: 34)

        let healthKitActivityRingView = HKActivityRingView()
        cellView.addSubview(healthKitActivityRingView)

        healthKitActivityRingView.translatesAutoresizingMaskIntoConstraints = false

        let width = cellView.frame.size.width
        let height = cellView.frame.size.height

        let length = min(width, height)

        NSLayoutConstraint.activate([
            healthKitActivityRingView.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
            healthKitActivityRingView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),

            healthKitActivityRingView.widthAnchor.constraint(equalToConstant: length),
            healthKitActivityRingView.heightAnchor.constraint(equalToConstant: length)
        ])

        healthKitActivityRingView.setActivitySummary(summary, animated: true)
    }

    func requestAccessForHealth() {
        self.healthStore = HKHealthStore()

        guard let healthStore else { return }

        let allTypes = Set([
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.activitySummaryType()
        ])

        healthStore.requestAuthorization(toShare: nil, read: allTypes) { success, _ in
            if success {
                self.readVitals()
            }
        }
    }

    private var lastDayPredicate: NSPredicate {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

        return HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
    }

    func readVitals() {
        readStepCount()
        readCaloriesBurned()
        readWorkout()
    }

    private func readStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: lastDayPredicate, options: .cumulativeSum, anchorDate: Date(), intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { _, results, _ in
            guard let results else { return }

            results.enumerateStatistics(from: Date(), to: Date()) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let steps = quantity.doubleValue(for: .count())
                    print("Steps: \(steps)")
                }
            }
        }

        healthStore?.execute(query)
    }

    private func readCaloriesBurned() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let query = HKStatisticsCollectionQuery(quantityType: calorieType, quantitySamplePredicate: lastDayPredicate, options: .cumulativeSum, anchorDate: Date(), intervalComponents: DateComponents(day: 1))

        query.initialResultsHandler = { _, results, _ in
            guard let results else { return }

            results.enumerateStatistics(from: Date(), to: Date()) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    let calories = quantity.doubleValue(for: .kilocalorie())
                    print("Calories: \(calories)")
                }
            }
        }

        healthStore?.execute(query)
    }

    private func readWorkout() {
        let workoutType = HKWorkoutType.workoutType()

        let query = HKSampleQuery(sampleType: workoutType, predicate: lastDayPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKWorkout] else { return }

            for sample in samples {
                print("Workout: \(sample.workoutActivityType.rawValue)")
            }
        }

        healthStore?.execute(query)
    }
}
