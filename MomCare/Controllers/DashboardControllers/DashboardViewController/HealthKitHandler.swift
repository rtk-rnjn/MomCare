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

        summary.activeEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 0)
        summary.activeEnergyBurnedGoal = HKQuantity(unit: .kilocalorie(), doubleValue: 0)
        summary.appleExerciseTime = HKQuantity(unit: .minute(), doubleValue: 0)
        summary.appleExerciseTimeGoal = HKQuantity(unit: .minute(), doubleValue: 0)
        summary.appleStandHours = HKQuantity(unit: .count(), doubleValue: 0)
        summary.appleStandHoursGoal = HKQuantity(unit: .count(), doubleValue: 0)

        let healthKitActivityRingView = HKActivityRingView()
        cellView.addSubview(healthKitActivityRingView)

        healthKitActivityRingView.translatesAutoresizingMaskIntoConstraints = false
        healthKitActivityRingView.backgroundColor = .clear

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
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
            HKObjectType.activitySummaryType()
        ])

        healthStore.requestAuthorization(toShare: nil, read: allTypes) { success, _ in
            if success {
                print("HealthKit permission granted")
            }
        }
    }
}
