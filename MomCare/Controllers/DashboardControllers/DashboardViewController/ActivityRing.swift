//
//  ActivityRing.swift
//  MomCare
//
//  Created by Ritik Ranjan on 13/02/25.
//

import Foundation
import HealthKit
import HealthKitUI

extension DashboardViewController {
    func addHKActivityRing(to cellView: UIView, withSummary summary: HKActivitySummary? = nil) {
        cellView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let ringColors: [UIColor] = [
            UIColor(hex: "DF433D"),
            UIColor(hex: "30D130"),
            UIColor(hex: "DA6239")
        ]

        Task {
            let maxValues = await extractMaxValues()
            let currentValues = await extractCurrentValues()
            
            DispatchQueue.main.async {
                self.drawActivityRings(in: cellView, colors: ringColors, maxValues: maxValues, currentValues: currentValues)
            }
        }
    }

    private func extractMaxValues() async -> [Double] {
        return [
            Utils.getStepGoal(week: MomCareUser.shared.user?.pregancyData?.week ?? 1),
            await Utils.getWorkoutGoal(),
            Utils.getCaloriesGoal(trimester: MomCareUser.shared.user?.pregancyData?.trimester ?? ""),
        ]
    }

    private func extractCurrentValues() async -> [Double] {
        async let stepCountValue = await HealthKitHandler.shared.readStepCount()
        async let exerciseMinutesValue = await HealthKitHandler.shared.readWorkout()
        async let caloriesBurnedValue = await HealthKitHandler.shared.readCaloriesBurned()
        
        return await [stepCountValue, exerciseMinutesValue, caloriesBurnedValue]
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
