import UIKit

class DietViewController: UIViewController {

    // MARK: Internal

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

    var dietTableViewController: DietTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareProgressRing()

        prepareProgressBars([proteinProgressBar, carbsProgressBar, fatsProgressBar])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupProgressBars()
        setupCaloricProgress()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedShowDietTableViewController" {
            dietTableViewController = segue.destination as? DietTableViewController
        }
    }

    func refresh() {
        setupProgressBars()
        setupCaloricProgress()
    }

    @IBSegueAction func test(_ coder: NSCoder) -> DietTableViewController? {
        return DietTableViewController(coder: coder, dietViewController: self)
    }

    @IBAction func unwindToMyPlanDiet(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private var backgroundLayer: CAShapeLayer!
    private var shapeLayer: CAShapeLayer!

    private func prepareProgressBars(_ progressBars: [UIProgressView]) {
        for progressBar in progressBars {
            progressBar.layer.cornerRadius = 5
            progressBar.clipsToBounds = true
            for subview in progressBar.subviews {
                subview.layer.cornerRadius = 5
                subview.clipsToBounds = true
            }
        }
    }

    private func setupCaloricProgress() {
        guard let plan = MomCareUser.shared.user?.plan else { return }
        animateKalcProgress(to: CGFloat(Float(plan.currentCaloriesIntake) / Float(plan.caloriesGoal!)))
        caloricValueLabel.text = String(plan.currentCaloriesIntake) + "/" + String(plan.caloriesGoal!)
    }

    private func setupProgressBars() {
        proteinProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        carbsProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
        fatsProgressBar.transform = CGAffineTransform(scaleX: 1, y: 2)

        guard let plan = MomCareUser.shared.user?.plan else { return }

        proteinProgressBar.progress = Float(plan.currentProteinIntake) / Float(plan.proteinGoal!)
        proteinProgressLabel.text = createProgressText(for: "protein")

        carbsProgressBar.progress = Float(plan.currentCarbsIntake) / Float(plan.carbsGoal!)
        carbsProgressLabel.text = createProgressText(for: "carbs")

        fatsProgressBar.progress = Float(plan.currentFatIntake) / Float(plan.fatGoal!)
        fatsProgressLabel.text = createProgressText(for: "fats")
    }

    private func createProgressText(for macronutrients: String) -> String {
        guard let plan = MomCareUser.shared.user?.plan else { fatalError() }
        switch macronutrients {
        case "protein":
            return "\(plan.currentProteinIntake)/\(plan.proteinGoal!)g"
        case "carbs":
            return "\(plan.currentCarbsIntake)/\(plan.carbsGoal!)g"
        case "fats":
            return "\(plan.currentFatIntake)/\(plan.fatGoal!)g"
        default:
            return ""
        }
    }

    private func prepareProgressRing() {

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

}
