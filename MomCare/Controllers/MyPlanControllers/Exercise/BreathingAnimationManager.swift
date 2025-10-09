//
//  BreathingAnimationManager.swift
//  MomCare
//
//  Created by Ritik Ranjan on 30/07/25.
//

import UIKit

protocol BreathingAnimationDelegate: AnyObject {
    func animationDidCompleteInhale()
    func animationDidCompleteExhale()
    func animationDidFinishExercise()
    func updateInstructionText(_ text: String)
    func showTimer(from count: Int)
    func hideTimer()
}

class BreathingAnimationManager {

    // MARK: Internal

    weak var delegate: (any BreathingAnimationDelegate)?
    var isInhaling = true
    var breathingCycles = 0

    @MainActor func setupAnimatedGradientBackground(in view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        let color1 = UIColor(hex: "#1e0d31")
        let color2 = UIColor(hex: "#3a2766")
        let color3 = UIColor(hex: "#6e4fa3")
        let color4 = UIColor(hex: "#bfaee0")
        let color5 = UIColor(hex: "#f7d6e0")

        gradientLayer.colors = [
            color1.cgColor,
            color2.cgColor,
            color3.cgColor,
            color4.cgColor,
            color5.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        animatedGradientLayer = gradientLayer
        animateGradientColors()
    }

    @MainActor func setupCircleLayers(in view: UIView) {
        circlesContainer.removeFromSuperlayer()
        circleLayers.removeAll()

        let containerSize = circleSize + (spreadDistance * 2)
        circlesContainer = CALayer()
        circlesContainer.frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        circlesContainer.position = view.center
        view.layer.addSublayer(circlesContainer)

        for i in 0...numberOfPetals {
            let circle = createCircleLayer(index: i)
            circle.position = CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY)
            circlesContainer.addSublayer(circle)
            circleLayers.append(circle)
        }
    }

    func startBreathingAnimation() {
        animationState = .playing
        animateBreathCycle()
    }

    func pauseAnimation() {
        animationState = .paused
        timer?.invalidate()

        if petalAnimationPhase != .none {
            let now = CACurrentMediaTime()
            let elapsed = now - petalAnimationStartTime
            petalAnimationRemaining = max(0, petalAnimationDuration - elapsed)
            petalPausedPositions = .init()

            for (index, circle) in circleLayers.enumerated() {
                if index == 0 { continue }
                let pos = circle.presentation()?.position ?? circle.position
                petalPausedPositions.append(pos)
                circle.removeAllAnimations()
                circle.position = pos
            }
        }

        nextStateWorkItem?.cancel()
        let timeElapsed = CACurrentMediaTime() - animationPhaseStartTime
        timeRemainingForPhase = animationDuration - timeElapsed
        if timeRemainingForPhase < 0 { timeRemainingForPhase = 0 }
    }

    func resumeAnimation() {
        animationState = .playing

        if petalAnimationPhase != .none && petalAnimationRemaining > 0 && !petalPausedPositions.isEmpty {
            for (i, circle) in circleLayers.enumerated() {
                if i == 0 { continue }
                let from = petalPausedPositions[i-1]
                let to: CGPoint
                if petalAnimationPhase == .expanding {
                    to = petalTargetPositions[i-1]
                } else {
                    to = CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY)
                }

                let animation = CABasicAnimation(keyPath: "position")
                animation.fromValue = from
                animation.toValue = to
                animation.duration = petalAnimationRemaining
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                circle.position = from
                circle.add(animation, forKey: "position")
            }

            petalAnimationStartTime = CACurrentMediaTime()
            petalAnimationDuration = petalAnimationRemaining

            if isInhaling {
                scheduleNextState(after: timeRemainingForPhase)
            }
            petalAnimationRemaining = 0
            petalPausedPositions = .init()
        }

        if isInhaling && petalAnimationPhase == .none {
            scheduleNextState(after: timeRemainingForPhase)
        }
    }

    func resetAnimation() {
        animationState = .ready
        breathingCycles = 0
        isInhaling = true

        circlesContainer.removeAllAnimations()
        for circle in circleLayers {
            circle.removeAllAnimations()
            circle.position = CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY)
        }

        timer?.invalidate()
        nextStateWorkItem?.cancel()
        petalAnimationPhase = .none
    }

    func finishExerciseAnimation() {
        animationState = .finished
        animateFlowerBloomAndShowMessage()
    }

    // MARK: Private

    private enum PetalAnimationPhase { case none, expanding, collapsing }
    private enum AnimationState { case ready, playing, paused, finished }

    private var animatedGradientLayer: CAGradientLayer?
    private var circlesContainer: CALayer = .init()
    private var circleLayers: [CAShapeLayer] = .init()
    private var timer: Timer?
    private var currentCount = 0

    private var petalAnimationPhase: PetalAnimationPhase = .none
    private var petalAnimationStartTime: TimeInterval = 0
    private var petalAnimationDuration: TimeInterval = 0
    private var petalAnimationRemaining: TimeInterval = 0
    private var petalTargetPositions: [CGPoint] = .init()
    private var petalPausedPositions: [CGPoint] = .init()
    private var animationState: AnimationState = .ready

    private var nextStateWorkItem: DispatchWorkItem?
    private var animationPhaseStartTime: TimeInterval = 0
    private var timeRemainingForPhase: TimeInterval = 0

    private let numberOfPetals = 6
    private let circleSize: CGFloat = 100
    private let animationDuration: TimeInterval = 4.0
    private let spreadDistance: CGFloat = 60
    private let textAnimationDuration: TimeInterval = 0.5

    private let petalColors: [UIColor] = [
        UIColor(hex: "#bfaee0"),
        UIColor(hex: "#f7d6e0"),
        UIColor(hex: "#e6d6f7"),
        UIColor(hex: "#f7d6ec"),
        UIColor(hex: "#ffd6d6"),
        UIColor(hex: "#e3c6f7")
    ]
    private let centerColor: UIColor = .init(hex: "#fff6f0")

    private func animateGradientColors() {
        guard let gradientLayer = animatedGradientLayer else { return }
        let fromColors = gradientLayer.colors
        let toColors: [CGColor] = [
            UIColor(hex: "#2a1a4d").cgColor,
            UIColor(hex: "#4b3577").cgColor,
            UIColor(hex: "#8c6fc9").cgColor,
            UIColor(hex: "#e3c6f7").cgColor,
            UIColor(hex: "#f7d6e0").cgColor
        ]

        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 6.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: "colorChange")
    }

    private func createCircleLayer(index: Int) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: -circleSize/2, y: -circleSize/2, width: circleSize, height: circleSize)
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: circleSize/2, y: circleSize/2),
            radius: circleSize/2,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        layer.path = circlePath.cgPath
        layer.shadowPath = circlePath.cgPath

        if index == 0 {
            layer.fillColor = centerColor.withAlphaComponent(0.85).cgColor
        } else {
            let color = petalColors[(index-1) % petalColors.count]
            layer.fillColor = color.withAlphaComponent(0.7).cgColor
            layer.shadowColor = color.withAlphaComponent(0.7).cgColor
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 16
            layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        return layer
    }

    private func animateBreathCycle() {
        if animationState != .playing { return }

        if isInhaling {
            delegate?.updateInstructionText("Inhale")
            delegate?.hideTimer()
            animateFlowerFormation {
                if self.animationState != .playing { return }
                self.delegate?.updateInstructionText("Hold")
                self.delegate?.showTimer(from: 4)
                self.scheduleNextState(after: self.animationDuration)
            }
        } else {
            currentCount = 4
            delegate?.updateInstructionText("Exhale")
            delegate?.hideTimer()
            animateFlowerCollapse {
                if self.animationState != .playing { return }
                self.breathingCycles += 1
                self.isInhaling = true
                self.delegate?.animationDidCompleteExhale()
                self.animateBreathCycle()
            }
        }
    }

    private func scheduleNextState(after delay: TimeInterval) {
        animationPhaseStartTime = CACurrentMediaTime()
        nextStateWorkItem = DispatchWorkItem { [weak self] in
            guard let self, animationState == .playing else { return }
            isInhaling = false
            delegate?.animationDidCompleteInhale()
            animateBreathCycle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: nextStateWorkItem!)
    }

    private func animateFlowerFormation(completion: @escaping () -> Void) {
        petalAnimationPhase = .expanding
        petalAnimationStartTime = CACurrentMediaTime()
        petalAnimationDuration = animationDuration
        petalAnimationRemaining = animationDuration
        petalTargetPositions = .init()
        petalPausedPositions = .init()

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.pulsePetals()
            completion()
        }

        for (index, circle) in circleLayers.enumerated() {
            if index == 0 { continue }
            let angle = (2.0 * .pi * CGFloat(index - 1)) / CGFloat(numberOfPetals)
            let destinationX = circlesContainer.bounds.midX + cos(angle) * spreadDistance
            let destinationY = circlesContainer.bounds.midY + sin(angle) * spreadDistance
            let destination = CGPoint(x: destinationX, y: destinationY)
            petalTargetPositions.append(destination)

            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = circle.presentation()?.position ?? circle.position
            animation.toValue = destination
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            circle.add(animation, forKey: "position")
        }
        CATransaction.commit()
    }

    private func pulsePetals() {
        for (index, circle) in circleLayers.enumerated() {
            if index == 0 { continue }
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.fromValue = 1.0
            pulse.toValue = 1.08
            pulse.duration = 0.7
            pulse.autoreverses = true
            pulse.repeatCount = 2
            pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            circle.add(pulse, forKey: "pulse")
        }
    }

    private func animateFlowerBloomAndShowMessage() {
        for (index, circle) in circleLayers.enumerated() {
            if index == 0 { continue }
            let bloom = CABasicAnimation(keyPath: "transform.scale")
            bloom.fromValue = 1.0
            bloom.toValue = 1.25
            bloom.duration = 1.2
            bloom.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            bloom.fillMode = .forwards
            bloom.isRemovedOnCompletion = false
            circle.add(bloom, forKey: "bloom")
        }

        delegate?.animationDidFinishExercise()
    }

    private func animateFlowerCollapse(completion: @escaping () -> Void) {
        petalAnimationPhase = .collapsing
        petalAnimationStartTime = CACurrentMediaTime()
        petalAnimationDuration = animationDuration
        petalAnimationRemaining = animationDuration
        petalTargetPositions = Array(repeating: CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY), count: numberOfPetals)
        petalPausedPositions = .init()

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        for (index, circle) in circleLayers.enumerated() {
            if index == 0 { continue }
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = circle.presentation()?.position ?? circle.position
            animation.toValue = CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY)
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            circle.add(animation, forKey: "position")
        }
        CATransaction.commit()
    }
}
