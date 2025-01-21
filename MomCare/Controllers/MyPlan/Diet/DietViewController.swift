import UIKit

class DietViewController: UIViewController {
    // Progress Bars Outlets
    @IBOutlet var proteinProgressBar: UIProgressView!
    @IBOutlet var carbsProgressBar: UIProgressView!
    @IBOutlet var fatsProgressBar: UIProgressView!
    @IBOutlet var proteinProgressLabel: UILabel!
    @IBOutlet var carbsProgressLabel: UILabel!
    @IBOutlet var fatsProgressLabel: UILabel!
    
    // Progress Ring Outlets
    @IBOutlet var progressContainerView: UIView!
    @IBOutlet var caloricValueLabel: UILabel!
    private var backgroundLayer: CAShapeLayer!
    private var shapeLayer: CAShapeLayer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateProgress(to: 0.55)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressRing()
        
        proteinProgressBar.layer.cornerRadius = 5
        proteinProgressBar.clipsToBounds = true
        proteinProgressBar.subviews.forEach { subview in
            subview.layer.cornerRadius = 5
            subview.clipsToBounds = true
        }
        carbsProgressBar.layer.cornerRadius = 5
        carbsProgressBar.clipsToBounds = true
        carbsProgressBar.subviews.forEach { subview in
            subview.layer.cornerRadius = 5
            subview.clipsToBounds = true
        }
            fatsProgressBar.layer.cornerRadius = 5
            fatsProgressBar.clipsToBounds = true
        fatsProgressBar.subviews.forEach { subview in
            subview.layer.cornerRadius = 5
            subview.clipsToBounds = true
        }
        
        proteinProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        carbsProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        fatsProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        proteinProgressBar.progress = 0.8
        proteinProgressLabel.text = "120/150g"
        carbsProgressBar.progress = 0.5
        carbsProgressLabel.text = "75/150g"
        fatsProgressBar.progress = 0.3
        fatsProgressLabel.text = "45/150g"
    }
    
    private func setupProgressRing() {

        let center = CGPoint(x: progressContainerView.bounds.midX, y: progressContainerView.bounds.midY)
        let radius: CGFloat = 60
        let lineWidth: CGFloat = 15

        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = Converters.convertHexToUIColor(hex: "D2ABAF").cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        
        progressContainerView.layer.addSublayer(backgroundLayer)
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = Converters.convertHexToUIColor(hex: "924350").cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        progressContainerView.layer.addSublayer(shapeLayer)
    }
    private func animateProgress(to value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = shapeLayer.strokeEnd
        animation.toValue = value
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shapeLayer.strokeEnd = value
        shapeLayer.add(animation, forKey: "progressAnimation")
    }
}
