import UIKit

class BreathingPlayerViewController: UIViewController {

    // MARK: Internal

    // MARK: - IBOutlets

    @IBOutlet var totalBreatingDuration: UILabel!

    // MARK: - Public Properties

    var exerciseProgressViewController: ExerciseProgressViewController?
    var remainingMinSec: Double = 0.0
    var completedPercentage: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAnimationManager()
        setupAccessibility()
    }

    // MARK: - Public Methods

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

    nonisolated func hideTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
            self.timerLabel.isHidden = true
            self.timerLabel.text = ""
        }
    }

    // MARK: Private

    // MARK: - Private Properties

    private enum PlayerState { case ready, playing, paused, finished }

    private let animationManager: BreathingAnimationManager = .init()
    private let assuringMessageLabel: UILabel = .init()
    private let instructionLabel: UILabel = .init()
    private let timerLabel: UILabel = .init()
    private var timer: Timer?
    private var currentCount = 0
    private var playerState: PlayerState = .ready
    private var startPauseButton: UIButton!
    private var stopButton: UIButton!
    private var exerciseTimer: Timer?
    private var secondsElapsed = 0

    private let textAnimationDuration: TimeInterval = 0.5
    private var totalBreathingTime: TimeInterval = 600

    // MARK: - Private Methods

    private func setupUI() {
        setupAssuringMessageLabel()
        setupInstructionLabel()
        setupTimerLabel()
        setupControlButtons()
        setupDynamicTypeSupport()
    }
    
    private func setupDynamicTypeSupport() {
        // Apply Dynamic Type to all labels
        totalBreatingDuration.font = UIFont.preferredFont(forTextStyle: .title1)
        totalBreatingDuration.adjustsFontForContentSizeCategory = true
        
        assuringMessageLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        assuringMessageLabel.adjustsFontForContentSizeCategory = true
        
        instructionLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        instructionLabel.adjustsFontForContentSizeCategory = true
        
        timerLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        timerLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func setupAccessibility() {
        // Duration label accessibility
        totalBreatingDuration.accessibilityLabel = "Remaining exercise time"
        totalBreatingDuration.accessibilityHint = "Shows time remaining in the breathing exercise"
        
        // Instruction label accessibility
        instructionLabel.accessibilityLabel = "Breathing instruction"
        instructionLabel.accessibilityHint = "Current breathing guidance"
        instructionLabel.accessibilityTraits = .updatesFrequently
        
        // Timer label accessibility
        timerLabel.accessibilityLabel = "Countdown timer"
        timerLabel.accessibilityHint = "Countdown before next breathing phase"
        timerLabel.accessibilityTraits = .updatesFrequently
        
        // Assuring message accessibility
        assuringMessageLabel.accessibilityLabel = "Completion message"
        assuringMessageLabel.accessibilityTraits = .staticText
    }

    private func setupAnimationManager() {
        animationManager.delegate = self
        animationManager.setupAnimatedGradientBackground(in: view)
        animationManager.setupCircleLayers(in: view)
    }

    private func setupAssuringMessageLabel() {
        assuringMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(assuringMessageLabel)
        NSLayoutConstraint.activate([
            assuringMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            assuringMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120)
        ])
        assuringMessageLabel.textColor = UIColor(hex: "#f7d6e0")
        assuringMessageLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        assuringMessageLabel.adjustsFontForContentSizeCategory = true
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
        instructionLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        instructionLabel.adjustsFontForContentSizeCategory = true
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
        timerLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        timerLabel.adjustsFontForContentSizeCategory = true
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

    private func setupControlButtons() {
        startPauseButton = UIButton(type: .system)
        startPauseButton.setTitle("Start", for: .normal)
        startPauseButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        startPauseButton.titleLabel?.adjustsFontForContentSizeCategory = true
        startPauseButton.setTitleColor(UIColor(hex: "#1e0d31"), for: .normal)
        startPauseButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        startPauseButton.layer.cornerRadius = 30
        startPauseButton.addTarget(self, action: #selector(startPauseButtonTapped), for: .touchUpInside)
        startPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility for start/pause button
        startPauseButton.accessibilityLabel = "Start breathing exercise"
        startPauseButton.accessibilityHint = "Starts or pauses the breathing exercise"
        startPauseButton.accessibilityTraits = .button

        stopButton = UIButton(type: .system)
        stopButton.setTitle("Stop", for: .normal)
        stopButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        stopButton.titleLabel?.adjustsFontForContentSizeCategory = true
        stopButton.setTitleColor(UIColor.white, for: .normal)
        stopButton.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        stopButton.layer.cornerRadius = 30
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.isHidden = true
        
        // Accessibility for stop button
        stopButton.accessibilityLabel = "Stop breathing exercise"
        stopButton.accessibilityHint = "Stops the current breathing exercise"
        stopButton.accessibilityTraits = .button

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
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44) // Ensure minimum touch target
        ])
    }

    @objc private func startPauseButtonTapped() {
        switch playerState {
        case .ready:
            playerState = .playing
            startExercise()
            startPauseButton.setTitle("Pause", for: .normal)
            startPauseButton.accessibilityLabel = "Pause breathing exercise"
            UIView.animate(withDuration: 0.3) {
                self.stopButton.isHidden = false
            }

        case .playing:
            playerState = .paused
            pauseExercise()
            startPauseButton.setTitle("Resume", for: .normal)
            startPauseButton.accessibilityLabel = "Resume breathing exercise"

        case .paused:
            playerState = .playing
            resumeExercise()
            startPauseButton.setTitle("Pause", for: .normal)
            startPauseButton.accessibilityLabel = "Pause breathing exercise"

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
        animationManager.startBreathingAnimation()
    }

    private func pauseExercise() {
        if playerState != .paused { return }

        exerciseTimer?.invalidate()
        animationManager.pauseAnimation()
    }

    private func resumeExercise() {
        if playerState != .playing { return }

        startMainTimer()
        animationManager.resumeAnimation()
    }

    private func resetExercise() {
        exerciseTimer?.invalidate()
        secondsElapsed = 0

        animationManager.resetAnimation()

        startPauseButton.setTitle("Start", for: .normal)
        startPauseButton.accessibilityLabel = "Start breathing exercise"

        stopButton.setTitle("Stop", for: .normal)
        stopButton.accessibilityLabel = "Stop breathing exercise"
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
            animationManager.finishExerciseAnimation()

            startPauseButton.setTitle("Restart", for: .normal)
            startPauseButton.accessibilityLabel = "Restart breathing exercise"

            stopButton.setTitle("Done", for: .normal)
            stopButton.accessibilityLabel = "Complete breathing exercise"
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

// MARK: - BreathingAnimationDelegate

extension BreathingPlayerViewController: BreathingAnimationDelegate {
    nonisolated func animationDidCompleteInhale() {
        // Handle inhale completion if needed
    }

    nonisolated func animationDidCompleteExhale() {
        // Handle exhale completion if needed
    }

    nonisolated func animationDidFinishExercise() {
        DispatchQueue.main.async {
            self.showAssuringMessage()
        }
    }

    nonisolated func updateInstructionText(_ text: String) {
        DispatchQueue.main.async {
            self.animateInstructionChange(to: text)
        }
    }

    nonisolated func showTimer(from count: Int) {
        DispatchQueue.main.async {
            self.startTimer(from: count)
        }
    }
}
