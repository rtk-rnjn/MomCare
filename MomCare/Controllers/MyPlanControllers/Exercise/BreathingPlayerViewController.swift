import UIKit

class BreathingPlayerViewController: UIViewController {

    // MARK: Internal

    @IBOutlet var totalBreatingDuration: UILabel!

    var exerciseProgressViewController: ExerciseProgressViewController?
    var remainingMinSec: Double = 0.0
    var completedPercentage: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimatedGradientBackground()
        setupCircleLayers()
        setupInstructionLabel()
        setupTimerLabel()
        setupAssuringMessageLabel()
        setupControlButtons()

        if let completionDuration: Double? = Utils.get(fromKey: "BreathingCompletionDuration", withDefaultValue: 0.0) {
            totalBreathingTime -= completionDuration ?? 0
        }
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

        while 10 * 60 - i > 0 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            DispatchQueue.main.async {
                i += 1
                let remainingSeconds = 10 * 60 - i

                let remainingMinutes = remainingSeconds / 60
                let remainingSecondsPart = remainingSeconds % 60
                self.remainingMinSec = Double(remainingMinutes) * 60 + Double(remainingSecondsPart)

                self.totalBreatingDuration.text = String(format: "%02d:%02d", remainingMinutes, remainingSecondsPart)
            }
        }
    }

    @IBAction func breathingStopButtonTapped(_ sender: UIButton) {
        let completedTime: Double = totalBreathingTime - remainingMinSec
        completedPercentage = (completedTime / totalBreathingTime * 100)
    }

    // MARK: Private

    private enum PetalAnimationPhase { case none, expanding, collapsing }

    private enum PlayerState { case ready, playing, paused, finished }

    private var animatedGradientLayer: CAGradientLayer?
    private var gradientAnimation: CABasicAnimation?

    private let assuringMessageLabel: UILabel = .init()
    private var circlesContainer: CALayer = .init()
    private var circleLayers: [CAShapeLayer] = []
    private var isInhaling = true
    private let instructionLabel: UILabel = .init()
    private let timerLabel: UILabel = .init()
    private var timer: Timer?
    private var currentCount = 0
    private var breathingCycles = 0

    private var petalAnimationPhase: PetalAnimationPhase = .none
    private var petalAnimationStartTime: TimeInterval = 0
    private var petalAnimationDuration: TimeInterval = 0
    private var petalAnimationRemaining: TimeInterval = 0
    private var petalTargetPositions: [CGPoint] = []
    private var petalPausedPositions: [CGPoint] = []
    private var playerState: PlayerState = .ready
    private var startPauseButton: UIButton!
    private var stopButton: UIButton!
    private var exerciseTimer: Timer?
    private var secondsElapsed = 0

    private var nextStateWorkItem: DispatchWorkItem?
    private var animationPhaseStartTime: TimeInterval = 0
    private var timeRemainingForPhase: TimeInterval = 0

    private let numberOfPetals = 6
    private let circleSize: CGFloat = 100
    private let animationDuration: TimeInterval = 4.0
    private let spreadDistance: CGFloat = 60
    private let textAnimationDuration: TimeInterval = 0.5 //
    private var totalBreathingTime: TimeInterval = 600
    private let petalColors: [UIColor] = [
        UIColor(hex: "#bfaee0"),
        UIColor(hex: "#f7d6e0"),
        UIColor(hex: "#e6d6f7"),
        UIColor(hex: "#f7d6ec"),
        UIColor(hex: "#ffd6d6"),
        UIColor(hex: "#e3c6f7")
    ]
    private let centerColor: UIColor = .init(hex: "#fff6f0")

    private func setupAnimatedGradientBackground() {
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

    private func setupAssuringMessageLabel() {
        assuringMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(assuringMessageLabel)
        NSLayoutConstraint.activate([
            assuringMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assuringMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120)
        ])
        assuringMessageLabel.textColor = UIColor(hex: "#f7d6e0")
        assuringMessageLabel.font = .systemFont(ofSize: 30, weight: .bold)
        assuringMessageLabel.textAlignment = .center
        assuringMessageLabel.numberOfLines = 0
        assuringMessageLabel.alpha = 0
        assuringMessageLabel.layer.shadowColor = UIColor.black.cgColor
        assuringMessageLabel.layer.shadowOpacity = 0.2
        assuringMessageLabel.layer.shadowRadius = 8
        assuringMessageLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        assuringMessageLabel.text = "You did amazing!\nTake this calm with you."
    }

    private func showAssuringMessage() {
        UIView.animate(withDuration: 1.2, delay: 0.2, options: [.curveEaseInOut]) {
            self.assuringMessageLabel.alpha = 1
        }
    }

    private func setupInstructionLabel() {
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120)
        ])
        instructionLabel.textColor = UIColor(hex: "#fff6f0")
        instructionLabel.font = .systemFont(ofSize: 36, weight: .semibold)
        instructionLabel.text = "Inhale"
        instructionLabel.alpha = 1
        instructionLabel.layer.shadowColor = UIColor.black.cgColor
        instructionLabel.layer.shadowOpacity = 0.18
        instructionLabel.layer.shadowRadius = 6
        instructionLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func animateInstructionChange(to newText: String) {
        UIView.animate(withDuration: textAnimationDuration, delay: 0, options: .curveLinear) {
            self.instructionLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.instructionLabel.alpha = 0
        }

        UIView.animate(withDuration: textAnimationDuration, delay: 0, options: .curveLinear) {} completion: { _ in

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
        timerLabel.textColor = UIColor(hex: "#bfaee0")
        timerLabel.font = .systemFont(ofSize: 34, weight: .medium)
        timerLabel.text = ""
        timerLabel.isHidden = true
        timerLabel.layer.shadowColor = UIColor.black.cgColor
        timerLabel.layer.shadowOpacity = 0.15
        timerLabel.layer.shadowRadius = 5
        timerLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    private func startTimer(from initialCount: Int = 4) {

        timer?.invalidate()
        currentCount = initialCount

        timerLabel.isHidden = false
        updateCurrentCount()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.updateCurrentCount()
            }
        }
    }

    private func updateCurrentCount() {
        if currentCount >= 1 {
            timerLabel.text = "\(currentCount)"
        }
        currentCount -= 1
    }

    private func setupCircleLayers() {

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

    private func hideTimer() {
        timer?.invalidate()
        timer = nil
        timerLabel.isHidden = true
        timerLabel.text = ""
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

    private func startBreathingAnimation() {
        animateBreathCycle()
    }

    private func animateBreathCycle() {
        if playerState != .playing { return }

        if isInhaling {
            animateInstructionChange(to: "Inhale")
            hideTimer()
            animateFlowerFormation {
                if self.playerState != .playing { return }
                self.animateInstructionChange(to: "Hold")
                self.startTimer()
                self.scheduleNextState(after: self.animationDuration)
            }
        } else {
            currentCount = 4
            animateInstructionChange(to: "Exhale")
            hideTimer()
            animateFlowerCollapse {
                if self.playerState != .playing { return }
                self.breathingCycles += 1
                self.isInhaling = true

                self.animateBreathCycle()
            }
        }
    }

    private func scheduleNextState(after delay: TimeInterval) {
        animationPhaseStartTime = CACurrentMediaTime()
        nextStateWorkItem = DispatchWorkItem { [weak self] in
            guard let self, playerState == .playing else { return }

            isInhaling = false
            animateBreathCycle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: nextStateWorkItem!)
    }

    private func animateFlowerFormation(completion: @escaping () -> Void) {
        petalAnimationPhase = .expanding
        petalAnimationStartTime = CACurrentMediaTime()
        petalAnimationDuration = animationDuration
        petalAnimationRemaining = animationDuration
        petalTargetPositions = []
        petalPausedPositions = []
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.showAssuringMessage()
        }
    }

    private func animateFlowerCollapse(completion: @escaping () -> Void) {
        petalAnimationPhase = .collapsing
        petalAnimationStartTime = CACurrentMediaTime()
        petalAnimationDuration = animationDuration
        petalAnimationRemaining = animationDuration
        petalTargetPositions = Array(repeating: CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY), count: numberOfPetals)
        petalPausedPositions = []
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

    private func setupControlButtons() {
        startPauseButton = UIButton(type: .system)
        startPauseButton.setTitle("Start", for: .normal)
        startPauseButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        startPauseButton.setTitleColor(UIColor(hex: "#1e0d31"), for: .normal)
        startPauseButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        startPauseButton.layer.cornerRadius = 30
        startPauseButton.addTarget(self, action: #selector(startPauseButtonTapped), for: .touchUpInside)
        startPauseButton.translatesAutoresizingMaskIntoConstraints = false

        stopButton = UIButton(type: .system)
        stopButton.setTitle("Stop", for: .normal)
        stopButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        stopButton.setTitleColor(UIColor.white, for: .normal)
        stopButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        stopButton.layer.cornerRadius = 30
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.isHidden = true

        let stackView = UIStackView(arrangedSubviews: [stopButton, startPauseButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func startPauseButtonTapped() {
        switch playerState {
        case .ready:

            playerState = .playing
            startExercise()
            startPauseButton.setTitle("Pause", for: .normal)
            UIView.animate(withDuration: 0.3) {
                self.stopButton.isHidden = false
            }

        case .playing:

            playerState = .paused
            pauseExercise()
            startPauseButton.setTitle("Resume", for: .normal)

        case .paused:

            playerState = .playing
            resumeExercise()
            startPauseButton.setTitle("Pause", for: .normal)

        case .finished:

            resetExercise()
        }
    }

    @objc private func stopButtonTapped() {
        pauseExercise()
        let alert = UIAlertController(title: "Stop Exercise", message: "Are you sure you want to stop the breathing exercise?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.resumeExercise()
        }))

        alert.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { _ in
            self.playerState = .finished
            self.resetExercise()
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true) {
                    Utils.save(forKey: "BreathingCompletionDuration", withValue: self.totalBreathingTime - self.remainingMinSec)

                    self.exerciseProgressViewController?.triggerRefresh()
                }
            }
        }))

        present(alert, animated: true)
    }

    private func startExercise() {

        secondsElapsed = 0
        updateMainTimer()
        startMainTimer()
        startBreathingAnimation()
    }

    private func pauseExercise() {
        if playerState != .paused { return }

        exerciseTimer?.invalidate()
        timer?.invalidate()

        if petalAnimationPhase != .none {
            let now = CACurrentMediaTime()
            let elapsed = now - petalAnimationStartTime
            petalAnimationRemaining = max(0, petalAnimationDuration - elapsed)
            petalPausedPositions = []
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

    private func resumeExercise() {
        if playerState != .playing { return }

        startMainTimer()

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
            petalPausedPositions = []
        }

        if !timerLabel.isHidden {
            startTimer(from: currentCount)
        }

        if isInhaling && petalAnimationPhase == .none {
            scheduleNextState(after: timeRemainingForPhase)
        }
    }

    private func resetExercise() {
        exerciseTimer?.invalidate()
        secondsElapsed = 0
        breathingCycles = 0
        isInhaling = true

        circlesContainer.removeAllAnimations()
        for circle in circleLayers {
            circle.removeAllAnimations()
            circle.position = CGPoint(x: circlesContainer.bounds.midX, y: circlesContainer.bounds.midY)
        }

        startPauseButton.setTitle("Start", for: .normal)

        stopButton.setTitle("Stop", for: .normal)
        stopButton.removeTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)

        UIView.animate(withDuration: 0.3) {
            self.stopButton.isHidden = true
            self.assuringMessageLabel.alpha = 0
            self.startPauseButton.alpha = 1
        }

        instructionLabel.text = "Inhale"
        totalBreatingDuration.text = String(format: "%02d:%02d", 5, 0)

        playerState = .ready
    }

    private func startMainTimer() {
        exerciseTimer?.invalidate()
        exerciseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.updateMainTimer()
            }
        }
    }

    private func updateMainTimer() {
        secondsElapsed += 1
        let remainingSeconds = Int(totalBreathingTime) - secondsElapsed
        if remainingSeconds <= 0 {
            totalBreatingDuration.text = "00:00"
            exerciseTimer?.invalidate()
            playerState = .finished
            animateFlowerBloomAndShowMessage()

            startPauseButton.setTitle("Restart", for: .normal)

            stopButton.setTitle("Done", for: .normal)
            stopButton.removeTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
            stopButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

            UIView.animate(withDuration: 0.5) {
                self.startPauseButton.alpha = 1
                self.stopButton.isHidden = false
            }
            return
        }

        let remainingMinutes = remainingSeconds / 60
        let remainingSecondsPart = remainingSeconds % 60
        remainingMinSec = Double(remainingMinutes) * 60 + Double(remainingSecondsPart)
        totalBreatingDuration.text = String(format: "%02d:%02d", remainingMinutes, remainingSecondsPart)
    }

    @objc private func doneButtonTapped() {

        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

}
