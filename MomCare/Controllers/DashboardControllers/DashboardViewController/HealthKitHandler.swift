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

    func requestAccessForHealth() {
        let readTypes = Set([
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)!,
            HKObjectType.activitySummaryType()
        ])

        let writeTypes = Set([
            HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
            HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)!
        ])

        DashboardViewController.healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, _ in
            if success {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }

    static func readStepCount(completionHandler: @escaping @Sendable (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result, let quantity = result.sumQuantity() else {
                completionHandler(0)
                return
            }

            let steps = quantity.doubleValue(for: .count())
            completionHandler(steps)
        }

        DashboardViewController.healthStore.execute(query)
    }

    static func readCaloriesBurned(completionHandler: @escaping @Sendable (Double) -> Void) {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result, let quantity = result.sumQuantity() else {
                completionHandler(0)
                return
            }

            let calories = quantity.doubleValue(for: .kilocalorie())
            completionHandler(calories)
        }

        DashboardViewController.healthStore.execute(query)
    }

    static func readWorkout(completionHandler: @escaping @Sendable (Double) -> Void) {
        let workoutType = HKWorkoutType.workoutType()

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let workouts = samples as? [HKWorkout] else {
                completionHandler(0)
                return
            }

            let totalMinutes = workouts.reduce(0) { $0 + ($1.duration / 60) }
            completionHandler(totalMinutes)
        }

        DashboardViewController.healthStore.execute(query)
    }

    static func readCaloriesIntake(completionHandler: @escaping @Sendable (Double) -> Void) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: calorieType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result, let quantity = result.sumQuantity() else {
                completionHandler(0)
                return
            }

            let calories = quantity.doubleValue(for: .kilocalorie())
            completionHandler(calories)
        }

        DashboardViewController.healthStore.execute(query)
    }

    static func readTotalFat(completionHandler: @escaping @Sendable (Double) -> Void) {
        let fatType = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: fatType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result, let quantity = result.sumQuantity() else {
                completionHandler(0)
                return
            }

            let fat = quantity.doubleValue(for: .gram())
            completionHandler(fat)
        }

        DashboardViewController.healthStore.execute(query)
    }

    static func readTotalProtein(completionHandler: @escaping @Sendable (Double) -> Void) {
        let proteinType = HKQuantityType.quantityType(forIdentifier: .dietaryProtein)

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: proteinType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result, let quantity = result.sumQuantity() else {
                completionHandler(0)
                return
            }

            let protein = quantity.doubleValue(for: .gram())
            completionHandler(protein)
        }

        DashboardViewController.healthStore.execute(query)
    }

    static func readTotalCarbs(completionHandler: @escaping @Sendable (Double) -> Void) {
        let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -1, to: now)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: carbsType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result, let quantity = result.sumQuantity() else {
                completionHandler(0)
                return
            }

            let carbs = quantity.doubleValue(for: .gram())
            completionHandler(carbs)
        }

        DashboardViewController.healthStore.execute(query)
    }

    func addHKActivityRing(to cellView: UIView, withSummary summary: HKActivitySummary? = nil) {
        cellView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let activitySummary = summary ?? sampleHKSummary()

        let ringColors: [UIColor] = [
            UIColor(hex: "DF433D"),
            UIColor(hex: "30D130"),
            UIColor(hex: "DA6239")
        ]

        let maxValues = extractMaxValues(from: activitySummary)
        let currentValues = extractCurrentValues(from: activitySummary)

        drawActivityRings(in: cellView, colors: ringColors, maxValues: maxValues, currentValues: currentValues)
    }

    private func sampleHKSummary() -> HKActivitySummary {
        let summary = HKActivitySummary()
        summary.activeEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 0.001)
        summary.activeEnergyBurnedGoal = HKQuantity(unit: .kilocalorie(), doubleValue: 1)

        summary.appleExerciseTime = HKQuantity(unit: .minute(), doubleValue: 0.001)
        summary.appleExerciseTimeGoal = HKQuantity(unit: .minute(), doubleValue: 1)

        summary.appleStandHours = HKQuantity(unit: .count(), doubleValue: 0.001)
        summary.appleStandHoursGoal = HKQuantity(unit: .count(), doubleValue: 1)
        return summary
    }

    private func extractMaxValues(from summary: HKActivitySummary) -> [Double] {
        return [
            summary.activeEnergyBurnedGoal.doubleValue(for: .kilocalorie()),
            summary.appleExerciseTimeGoal.doubleValue(for: .minute()),
            summary.appleStandHoursGoal.doubleValue(for: .count())
        ]
    }

    private func extractCurrentValues(from summary: HKActivitySummary) -> [Double] {
        return [
            summary.activeEnergyBurned.doubleValue(for: .kilocalorie()),
            summary.appleExerciseTime.doubleValue(for: .minute()),
            summary.appleStandHours.doubleValue(for: .count())
        ]
    }

    private func drawActivityRings(in cellView: UIView, colors: [UIColor], maxValues: [Double], currentValues: [Double]) {
        let ringSize = min(cellView.bounds.width, cellView.bounds.height)
        let ringWidth: CGFloat = ringSize * 0.1
        let radius: CGFloat = (ringSize / 2) - (ringWidth / 2)
        let center = CGPoint(x: cellView.bounds.midX, y: cellView.bounds.midY)

        for (index, color) in colors.enumerated() {
            let startAngle: CGFloat = -.pi / 2
            let endAngle: CGFloat = startAngle + (.pi * 2 * CGFloat(currentValues[index] / maxValues[index]))

            let backgroundLayer = createRingLayer(center: center, radius: radius - (CGFloat(index) * ringWidth * 1.2), color: color.withAlphaComponent(0.15), lineWidth: ringWidth, startAngle: 0, endAngle: .pi * 2)
            let progressLayer = createRingLayer(center: center, radius: radius - (CGFloat(index) * ringWidth * 1.2), color: color, lineWidth: ringWidth, startAngle: startAngle, endAngle: endAngle)

            cellView.layer.addSublayer(backgroundLayer)
            cellView.layer.addSublayer(progressLayer)

            animateProgressLayer(progressLayer)
        }
    }

    private func createRingLayer(center: CGPoint, radius: CGFloat, color: UIColor, lineWidth: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CAShapeLayer { // swiftlint:disable:this function_parameter_count
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
    }

    private func animateProgressLayer(_ layer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "progressAnim")
        layer.strokeEnd = 1.0
    }

}
