import UIKit

class ExerciseVideoPlayerViewController: UIViewController {
    
    private var circlesContainer = CALayer()
    private var circleLayers: [CAShapeLayer] = []
    private var isInhaling = true
    private let instructionLabel = UILabel()
    private let timerLabel = UILabel()  // New timer label
    private var timer: Timer?           // Timer for updating countdown
    private var currentCount = 0
    
    // Configuration
    private let numberOfPetals = 6
    private let circleSize: CGFloat = 100
    private let animationDuration: TimeInterval = 4.0
    private let spreadDistance: CGFloat = 50  // How far circles spread to form the flower
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateGradientBackground()
        setupCircleLayers()
        setupInstructionLabel()
        setupTimerLabel()
        startBreathingAnimation()
    }
    
    func updateGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        let upperColor = Converters.convertHexToUIColor(hex: "#1e0d31")
        let middleColor = Converters.convertHexToUIColor(hex: "#13102f")
        let bottomColor = Converters.convertHexToUIColor(hex: "#0f102e")
        
        gradientLayer.colors = [
            upperColor.withAlphaComponent(1.0).cgColor,
            middleColor.withAlphaComponent(1.0).cgColor,
            bottomColor.withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupInstructionLabel() {
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
        ])
        
        instructionLabel.textColor = .white
        instructionLabel.font = .systemFont(ofSize: 24, weight: .medium)
        instructionLabel.text = "Inhale"
    }
    
    private func setupTimerLabel() {
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(timerLabel)
            
            NSLayoutConstraint.activate([
                timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                timerLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20)
            ])
            
            timerLabel.textColor = .white
            timerLabel.font = .systemFont(ofSize: 20, weight: .regular)
            timerLabel.text = ""
        }
    
    private func startTimer() {
            // Reset and invalidate existing timer if any
            timer?.invalidate()
            currentCount = 4
            
            // Start new timer
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                if self.currentCount <= Int(self.animationDuration) {
                    // Update timer label with current count
                    self.timerLabel.text = "\(self.currentCount)"
                }
                self.currentCount -= 1
            }
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
            instructionLabel.text = "Inhale"
            animateFlowerFormation {
                self.instructionLabel.text = "Hold"
                self.startTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
                    self.isInhaling = false
                    self.animateBreathCycle()
                }
            }
        } else {
            instructionLabel.text = "Exhale"
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
        
        // Animate each circle back to center
        for (index, circle) in circleLayers.enumerated() {
            if index == 0 {
                // Center circle stays put
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
    
    // Cleanup timer when view is dismissed
        deinit {
            timer?.invalidate()
            timer = nil
        }
}
