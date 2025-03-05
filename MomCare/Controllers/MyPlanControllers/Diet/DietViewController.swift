import UIKit
import HealthKit

class DietViewController: UIViewController {

    // MARK: Internal

    @IBOutlet var proteinProgressBar: UIProgressView!
    @IBOutlet var carbsProgressBar: UIProgressView!
    @IBOutlet var fatsProgressBar: UIProgressView!
    @IBOutlet var proteinProgressLabel: UILabel!
    @IBOutlet var carbsProgressLabel: UILabel!
    @IBOutlet var fatsProgressLabel: UILabel!

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

        prepareProgressBars([proteinProgressBar, carbsProgressBar, fatsProgressBar])
        prepareCaloricProgress()
        prepareProgress()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedShowDietTableViewController" {
            dietTableViewController = segue.destination as? DietTableViewController
        }
    }

    static func addCalories(energy: Double, consumed: Bool) {
        let date = Date()

        let energyType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        let energyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: energy * (consumed ? 1 : -1))

        let energySample = HKQuantitySample(
            type: energyType,
            quantity: energyQuantity,
            start: date,
            end: date
        )

        DashboardViewController.healthStore.save(energySample) { success, _ in
            if success {}
        }
    }

    static func addProtein(protein: Double, consumed: Bool) {
        let date = Date()

        let proteinType = HKQuantityType.quantityType(forIdentifier: .dietaryProtein)!
        let proteinQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: protein * (consumed ? 1 : -1))

        let proteinSample = HKQuantitySample(
            type: proteinType,
            quantity: proteinQuantity,
            start: date,
            end: date
        )

        DashboardViewController.healthStore.save(proteinSample) { success, _ in
            if success {}
        }
    }

    static func addCarbs(carbs: Double, consumed: Bool) {
        let date = Date()

        let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)!
        let carbsQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: carbs * (consumed ? 1 : -1))

        let carbsSample = HKQuantitySample(
            type: carbsType,
            quantity: carbsQuantity,
            start: date,
            end: date
        )

        DashboardViewController.healthStore.save(carbsSample) { success, _ in
            if success {}
        }
    }

    static func addFats(fats: Double, consumed: Bool) {
        let date = Date()

        let fatsType = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)!
        let fatsQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: fats * (consumed ? 1 : -1))

        let fatsSample = HKQuantitySample(
            type: fatsType,
            quantity: fatsQuantity,
            start: date,
            end: date
        )

        DashboardViewController.healthStore.save(fatsSample) { success, _ in
            if success {}
        }
    }

    func refresh() {
        prepareProgressBars([proteinProgressBar, carbsProgressBar, fatsProgressBar])
        prepareCaloricProgress()
        prepareProgress()
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
            progressBar.transform = CGAffineTransform(scaleX: 1, y: 2)
            for subview in progressBar.subviews {
                subview.layer.cornerRadius = 5
                subview.clipsToBounds = true
            }
        }
    }

    private func prepareProgress() {
        guard let dietTableViewController else { return }
        let proteinGoal = dietTableViewController.proteinGoal
        let carbsGoal = dietTableViewController.carbsGoal
        let fatsGoal = dietTableViewController.fatsGoal

        prepareProtienProgress(with: proteinGoal)
        prepareCarbsProgress(with: carbsGoal)
        prepareFatsProgress(with: fatsGoal)
    }

    private func prepareProtienProgress(with goal: Double) {
        DashboardViewController.readTotalProtein { protienConsumed in
            DispatchQueue.main.async {
                self.proteinProgressBar.progress = Float(protienConsumed / goal)
                self.proteinProgressLabel.text = "\(protienConsumed) / \(goal)g"
            }
        }
    }

    private func prepareCarbsProgress(with goal: Double) {
        DashboardViewController.readTotalCarbs { carbsConsumed in
            DispatchQueue.main.async {
                self.carbsProgressBar.progress = Float(carbsConsumed / goal)
                self.carbsProgressLabel.text = "\(carbsConsumed) / \(goal)g"
            }
        }
    }

    private func prepareFatsProgress(with goal: Double) {
        DashboardViewController.readTotalFat { fatsConsumed in
            DispatchQueue.main.async {
                self.fatsProgressBar.progress = Float(fatsConsumed / goal)
                self.fatsProgressLabel.text = "\(fatsConsumed) / \(goal)g"
            }
        }
    }

    private func prepareCaloricProgress() {
        DashboardViewController.readCaloriesIntake { currentCaloriesIntake in
            DispatchQueue.main.async {
                guard let dueDate = MomCareUser.shared.user?.medicalData?.dueDate else { return }
                guard let pregnancyData = Utils.pregnancyWeekAndDay(dueDate: dueDate) else { return }
                let goal = Utils.getCaloriesGoal(trimester: pregnancyData.trimester)

                let currentCaloriesGoal = goal

                self.animateKalcProgress(to: CGFloat(Float(currentCaloriesIntake) / Float(currentCaloriesGoal)))
                self.caloricValueLabel.text = "\(Int(currentCaloriesIntake))/\(Int(currentCaloriesGoal))"
            }
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
        backgroundLayer.strokeColor = UIColor(hex: "D2ABAF").cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        progressContainerView.layer.addSublayer(backgroundLayer)

        shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = UIColor(hex: "924350").cgColor
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
