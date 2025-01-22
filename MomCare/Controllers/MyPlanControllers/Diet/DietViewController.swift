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
    
    var dietTableViewController: DietTableViewController?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        setupProgressBars()
        setupCaloricProgress()
    }
    
    func refresh() {
        setupProgressBars()
        setupCaloricProgress()
    }

    private func setupCaloricProgress() {
        animateKalcProgress(to: CGFloat((Float(MomCareUser.shared.diet.plan.currentCaloriesIntake) / Float(MomCareUser.shared.diet.plan.caloriesGoal!))))
        
        caloricValueLabel.text = String(MomCareUser.shared.diet.plan.currentCaloriesIntake) + "/" + String(MomCareUser.shared.diet.plan.caloriesGoal!)
    }

    private func setupProgressBars() {
        proteinProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        carbsProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        fatsProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)

        proteinProgressBar.progress = Float(MomCareUser.shared.diet.plan.currentProteinIntake) / Float(MomCareUser.shared.diet.plan.proteinGoal!)
        proteinProgressLabel.text = createProgressText(for: "protein")

        carbsProgressBar.progress = Float(MomCareUser.shared.diet.plan.currentCarbsIntake) / Float(MomCareUser.shared.diet.plan.carbsGoal!)
        carbsProgressLabel.text = createProgressText(for: "carbs")

        fatsProgressBar.progress = Float(MomCareUser.shared.diet.plan.currentFatIntake) / Float(MomCareUser.shared.diet.plan.fatGoal!)
        fatsProgressLabel.text = createProgressText(for: "fats")
    }
    
    private func createProgressText(for macronutrients: String) -> String {
        switch macronutrients {
        case "protein":
            return "\(MomCareUser.shared.diet.plan.currentProteinIntake)/\(MomCareUser.shared.diet.plan.proteinGoal!)g"
        case "carbs":
            return "\(MomCareUser.shared.diet.plan.currentCarbsIntake)/\(MomCareUser.shared.diet.plan.carbsGoal!)g"
        case "fats":
            return "\(MomCareUser.shared.diet.plan.currentFatIntake)/\(MomCareUser.shared.diet.plan.fatGoal!)g"
        default:
            return ""
        }
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

    private func animateKalcProgress(to value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = shapeLayer.strokeEnd
        animation.toValue = value
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shapeLayer.strokeEnd = value
        shapeLayer.add(animation, forKey: "progressAnimation")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedShowDietTableViewController" {
            dietTableViewController = segue.destination as? DietTableViewController
        }
    }
}
