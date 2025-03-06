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
            if let dietTableViewController = segue.destination as? DietTableViewController {
                self.dietTableViewController = dietTableViewController
                dietTableViewController.dietViewController = self
            }
        }
    }

    static func addNutrient(typeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, amount: Double, consumed: Bool) {
        let date = Date()
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else { return }
        let quantity = HKQuantity(unit: unit, doubleValue: amount * (consumed ? 1 : -1))
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
        DashboardViewController.healthStore.save(sample) { success, _ in if success {} }
    }

    static func addCalories(energy: Double, consumed: Bool) {
        addNutrient(typeIdentifier: .dietaryEnergyConsumed, unit: .kilocalorie(), amount: energy, consumed: consumed)
    }

    static func addProtein(protein: Double, consumed: Bool) {
        addNutrient(typeIdentifier: .dietaryProtein, unit: .gram(), amount: protein, consumed: consumed)
    }

    static func addCarbs(carbs: Double, consumed: Bool) {
        addNutrient(typeIdentifier: .dietaryCarbohydrates, unit: .gram(), amount: carbs, consumed: consumed)
    }

    static func addFats(fats: Double, consumed: Bool) {
        addNutrient(typeIdentifier: .dietaryFatTotal, unit: .gram(), amount: fats, consumed: consumed)
    }

    func refresh() {
        prepareProgressBars([proteinProgressBar, carbsProgressBar, fatsProgressBar])
        prepareCaloricProgress()
        prepareProgress()
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
            progressBar.subviews.forEach { $0.layer.cornerRadius = 5; $0.clipsToBounds = true }
        }
    }

    private func prepareProgress() {
        guard let dietTableViewController else { return }
        let goals = [
            (proteinProgressBar, proteinProgressLabel, dietTableViewController.proteinGoal, DashboardViewController.readTotalProtein),
            (carbsProgressBar, carbsProgressLabel, dietTableViewController.carbsGoal, DashboardViewController.readTotalCarbs),
            (fatsProgressBar, fatsProgressLabel, dietTableViewController.fatsGoal, DashboardViewController.readTotalFat)
        ]

        for (progressBar, label, goal, readFunction) in goals {
            readFunction { consumed in
                DispatchQueue.main.async {
                    progressBar?.progress = Float(consumed / goal)
                    label?.text = "\(consumed) / \(goal)g"
                }
            }
        }
    }

    private func prepareCaloricProgress() {
        DashboardViewController.readCaloriesIntake { currentCaloriesIntake in
            DispatchQueue.main.async {
                guard let dueDate = MomCareUser.shared.user?.medicalData?.dueDate,
                      let pregnancyData = Utils.pregnancyWeekAndDay(dueDate: dueDate) else { return }
                let goal = Utils.getCaloriesGoal(trimester: pregnancyData.trimester)
                self.animateKalcProgress(to: CGFloat(Float(currentCaloriesIntake) / Float(goal)))
                self.caloricValueLabel.text = "\(Int(currentCaloriesIntake))/\(Int(goal))"
            }
        }
    }

    private func prepareProgressRing() {
        let center = CGPoint(x: progressContainerView.bounds.midX, y: progressContainerView.bounds.midY)
        let radius: CGFloat = 60
        let lineWidth: CGFloat = 15
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 3 / 2, clockwise: true)

        backgroundLayer = createShapeLayer(path: circlePath.cgPath, lineWidth: lineWidth, strokeColor: UIColor(hex: "D2ABAF").cgColor)
        shapeLayer = createShapeLayer(path: circlePath.cgPath, lineWidth: lineWidth, strokeColor: UIColor(hex: "924350").cgColor)

        progressContainerView.layer.addSublayer(backgroundLayer)
        progressContainerView.layer.addSublayer(shapeLayer)
    }

    private func createShapeLayer(path: CGPath, lineWidth: CGFloat, strokeColor: CGColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path
        layer.lineWidth = lineWidth
        layer.strokeColor = strokeColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
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
