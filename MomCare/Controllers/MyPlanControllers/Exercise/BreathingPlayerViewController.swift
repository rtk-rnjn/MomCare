import UIKit

class BreathingPlayerViewController: UIViewController {

    // MARK: Internal

    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var instructionTimerLabel: UILabel!

    @IBOutlet var animationView: UIView!
    @IBOutlet var startPauseButton: UIButton!
    @IBOutlet var stopButton: UIButton!

    @IBOutlet var overallTimerLabel: UILabel!

    var duration: Int = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        overallTimerLabel.text = formatTimerLabel(duration)
        instructionLabel.text = "Ready"

        createInitialFlower()
    }

    @IBAction func startPauseButtonTapped(_ sender: UIButton) {
        if isPaused {
            startBreathing()
        } else {
            pauseBreathing()
        }
        isPaused.toggle()
    }

    @IBAction func stopButtonTapped(_ sender: UIButton) {
        pauseBreathing()
        isPaused = true

        let cancelAction = AlertActionHandler(title: "Cancel", style: .cancel, handler: nil)
        var confirmAction = AlertActionHandler(title: "Confirm", style: .destructive) { _ in
            self.dismiss(animated: true)
        }
        let alert = Utils.getAlert(title: "Stop Session", message: "Do you want to stop the breathing session?", actions: [cancelAction, confirmAction])

        if duration <= 0 {
            alert.message = "The session is already completed. Do you want to dismiss?"
            confirmAction.handler = { _ in
                self.dismiss(animated: true)
            }
        } else {
            alert.message = "Do you want to stop the breathing session?"
        }
        present(alert, animated: true)
    }

    // MARK: Private

    private var isPaused = true
    private var instructions: [String] = ["Inhale", "Hold", "Exhale"]
    private var holdDuration: Int = 4

    private var circles: [CAShapeLayer] = []

    private var runnerTask: Task<Void, Never>?

    private var phaseIndex: Int = 0
    private var phaseRemaining: Int = 4

    private func formatTimerLabel(_ time: Int) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startBreathing() {
        startPauseButton.setTitle("Pause", for: .normal)
        runnerTask = Task { await runner() }
    }

    private func pauseBreathing() {
        startPauseButton.setTitle("Start", for: .normal)
        runnerTask?.cancel()
    }

    private func runner() async {
        while duration >= 0 && !Task.isCancelled && !isPaused {
            let currentInstruction = instructions[phaseIndex % instructions.count]

            await MainActor.run {
                updateUI(for: currentInstruction)
                triggerAnimationIfNeeded(for: currentInstruction)
            }

            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
            duration -= 1
            phaseRemaining -= 1

            if phaseRemaining == 0 {
                phaseIndex += 1
                phaseRemaining = holdDuration
            }
        }

        await MainActor.run {
            if duration <= 0 {
                showCompletion()
            } else {
                updateUI(for: instructions[phaseIndex % instructions.count])
            }
        }
    }

    @MainActor
    private func updateUI(for instruction: String) {
        instructionLabel.text = instruction
        overallTimerLabel.text = formatTimerLabel(duration)

        if instruction == "Hold" {
            instructionTimerLabel.text = "\(phaseRemaining)"
        } else {
            instructionTimerLabel.text = "--"
        }
    }

    @MainActor
    private func triggerAnimationIfNeeded(for instruction: String) {
        if phaseRemaining == holdDuration {
            if instruction == "Inhale" {
                openAllFlowerPetals()
            } else if instruction == "Exhale" {
                closeAllFlowerPetals()
            }
        }
    }

    @MainActor
    private func showCompletion() {
        instructionLabel.text = "Completed 🎉"
        instructionTimerLabel.text = "--"
        overallTimerLabel.text = "00:00"
        startPauseButton.setTitle("Start", for: .normal)
    }

}

extension BreathingPlayerViewController {
    func drawCenteredFilledCircle(in view: UIView, radius: CGFloat, fillColor: UIColor) -> CAShapeLayer {
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = nil

        view.layer.addSublayer(shapeLayer)

        return shapeLayer
    }

    func createInitialFlower() {
        let numberOfCircles = 6
        let radius: CGFloat = view.bounds.width / 6

        for _ in 0..<numberOfCircles {
            let layer = drawCenteredFilledCircle(in: animationView, radius: radius, fillColor: UIColor.systemRed.withAlphaComponent(0.5))

            circles.append(layer)
        }
    }

    func animateOpenFlowerPetal(shapeLayer: CAShapeLayer, angle: CGFloat) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = shapeLayer.position
        let distance = view.bounds.width / 6
        animation.toValue = CGPoint(x: shapeLayer.position.x + distance * cos(angle), y: shapeLayer.position.y + distance * sin(angle))
        animation.duration = Double(holdDuration) / 2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards

        animation.isRemovedOnCompletion = false
        shapeLayer.add(animation, forKey: "flowerPetalOpenAnimation")
    }

    func animateCloseFlowerPetal(shapeLayer: CAShapeLayer, angle: CGFloat) {
        let animation = CABasicAnimation(keyPath: "position")
        let distance = view.bounds.width / 6
        animation.fromValue = CGPoint(
            x: shapeLayer.position.x + distance * cos(angle),
            y: shapeLayer.position.y + distance * sin(angle)
        )
        animation.toValue = shapeLayer.position
        animation.duration = Double(holdDuration) / 2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        shapeLayer.add(animation, forKey: "flowerPetalCloseAnimation")
    }

    func openAllFlowerPetals() {
        for (index, circle) in circles.enumerated() {
            let angle = CGFloat(index) * (CGFloat.pi * 2 / CGFloat(circles.count))
            animateOpenFlowerPetal(shapeLayer: circle, angle: angle)
        }
    }

    func closeAllFlowerPetals() {
        for (index, circle) in circles.enumerated() {
            let angle = CGFloat(index) * (CGFloat.pi * 2 / CGFloat(circles.count))
            animateCloseFlowerPetal(shapeLayer: circle, angle: angle)
        }
    }

}
