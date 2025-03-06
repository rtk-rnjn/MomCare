import UIKit

class BreathingPlayerViewController: UIViewController {

    // MARK: Internal

    @IBOutlet var totalBreatingDuration: UILabel!

    var remainingMinSec: Double = 0.0
    var completedPercentage: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateGradientBackground()
        setupCircleLayers()
        setupInstructionLabel()
        setupTimerLabel()

        Task {
            await exrciseDurationSetup()
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startBreathingAnimation() // starting animation when the screen is fully loaded
    }

    func updateGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        let upperColor = UIColor(hex: "#1e0d31")
        let middleColor = UIColor(hex: "#13102f")
        let bottomColor = UIColor(hex: "#0f102e")

        gradientLayer.colors = [
            upperColor.withAlphaComponent(1.0).cgColor,
            middleColor.withAlphaComponent(1.0).cgColor,
            bottomColor.withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func exrciseDurationSetup() async {
        var i = 0

        while 5 * 60 - i > 0 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            DispatchQueue.main.async {
                i += 1
                let remainingSeconds = 5 * 60 - i

                let remainingMinutes = remainingSeconds / 60
                let remainingSecondsPart = remainingSeconds % 60
                self.remainingMinSec = Double(remainingMinutes) * 60 + Double(remainingSecondsPart)

                self.totalBreatingDuration.text = String(format: "%02d:%02d", remainingMinutes, remainingSecondsPart)
            }
        }
    }

    @IBAction func breathingStopButtonTapped(_ sender: UIButton) {
        let remainingTime: Double = remainingMinSec
        let completedTime: Double = totalBreathingTime - remainingTime
        completedPercentage = (completedTime / totalBreathingTime * 100)
    }

    // MARK: Private

    private var circlesContainer: CALayer = .init()
    private var circleLayers: [CAShapeLayer] = []
    private var isInhaling = true
    private let instructionLabel: UILabel = .init()
    private let timerLabel: UILabel = .init() // New timer label
    private var timer: Timer? // Timer for updating countdown
    private var currentCount = 0

    // Configuration
    private let numberOfPetals = 6
    private let circleSize: CGFloat = 100
    private let animationDuration: TimeInterval = 4.0
    private let spreadDistance: CGFloat = 50 // How far circles spread to form the flower
    private let textAnimationDuration: TimeInterval = 0.5 //
    private let totalBreathingTime: Double = 300

    private func setupInstructionLabel() {
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120)
        ])

        instructionLabel.textColor = .white
        instructionLabel.font = .systemFont(ofSize: 30, weight: .medium)
        instructionLabel.text = "Inhale"
        instructionLabel.alpha = 1
    }

    private func animateInstructionChange(to newText: String) {
        UIView.animate(withDuration: textAnimationDuration, delay: 0, options: .curveLinear) {
            self.instructionLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.instructionLabel.alpha = 0
        }

        // Animate new text up and fade in
        UIView.animate(withDuration: textAnimationDuration, delay: 0, options: .curveLinear) {} completion: { _ in
            // Reset for next transition
            self.instructionLabel.text = newText
            self.instructionLabel.transform = .identity
            self.instructionLabel.alpha = 1
        }
    }

    private func setupTimerLabel() {
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)

        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20)
        ])

        timerLabel.textColor = .white
        timerLabel.font = .systemFont(ofSize: 30, weight: .regular)
        timerLabel.text = ""
        timerLabel.isHidden = true
    }

    private func startTimer() {
        // Reset and invalidate existing timer if any
        timer?.invalidate()
        currentCount = 4

        timerLabel.isHidden = false

        // Start new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.updateCurrentCount()
            }
        }

    }

    private func updateCurrentCount() {
        if currentCount <= Int(animationDuration) {
            timerLabel.text = "\(currentCount)"
        }
        currentCount -= 1
    }

    private func setupCircleLayers() {
        // Setup container
        let containerSize = circleSize + (spreadDistance * 2)
        circlesContainer.frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        circlesContainer.position = view.center
        view.layer.addSublayer(circlesContainer)

        // Create all circles (center + petals)
        for _ in 0...numberOfPetals {
            let circle = createCircleLayer()
            // All circles start at center
            circle.position = CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY)
            circlesContainer.addSublayer(circle)
            circleLayers.append(circle)
        }
    }

    private func hideTimer() {
        timer?.invalidate()
        timer = nil
        timerLabel.isHidden = true
        timerLabel.text = ""
    }

    private func createCircleLayer() -> CAShapeLayer {
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
        layer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        return layer
    }

    private func startBreathingAnimation() {
        animateBreathCycle()
    }

    private func animateBreathCycle() {
        if isInhaling {
            animateInstructionChange(to: "Inhale") //
            hideTimer()
            animateFlowerFormation {
                self.animateInstructionChange(to: "Hold") //
                self.startTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
                    self.isInhaling = false
                    self.animateBreathCycle()
                }
            }
        } else {
            currentCount = 4
            animateInstructionChange(to: "Exhale") //
            hideTimer()
            animateFlowerCollapse {
                self.isInhaling = true
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.animateBreathCycle()
                }
            }
        }
    }

    private func animateFlowerFormation(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        // Animate each circle to its position
        for (index, circle) in circleLayers.enumerated() {
            if index == 0 {
                // Center circle stays put
                continue
            }

            let angle = (2.0 * .pi * CGFloat(index - 1)) / CGFloat(numberOfPetals)
            let destinationX = circlesContainer.bounds.midX + cos(angle) * spreadDistance
            let destinationY = circlesContainer.bounds.midY + sin(angle) * spreadDistance

            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY)
            animation.toValue = CGPoint(x: destinationX, y: destinationY)
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            circle.add(animation, forKey: "position")
        }

        CATransaction.commit()
    }

    private func animateFlowerCollapse(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        for (index, circle) in circleLayers.enumerated() {
            if index == 0 {
                continue
            }

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
