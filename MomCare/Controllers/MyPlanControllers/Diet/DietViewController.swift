import UIKit
import HealthKit
import OSLog

private let logger: Logger = .init(subsystem: "com.momcare.DietViewController", category: "ViewController")

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
    @IBOutlet var literalKcalLabel: UILabel!

    @IBOutlet var literalProtienLabel: UILabel!
    @IBOutlet var literalCarbsLabel: UILabel!
    @IBOutlet var literalFatsLabel: UILabel!

    var dietTableViewController: DietTableViewController?

    var myPlanViewController: MyPlanViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        literalFatsLabel.text = "Fats"
        literalCarbsLabel.text = "Carbs"
        literalProtienLabel.text = "Protein"

        prepareProgressRing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshStats()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedShowDietTableViewController" {
            if let dietTableViewController = segue.destination as? DietTableViewController {
                self.dietTableViewController = dietTableViewController
                dietTableViewController.dietViewController = self
            }
        }
    }

    func startShimmering() {
        caloricValueLabel.startShimmer()
        literalKcalLabel.startShimmer()

        proteinProgressLabel.startShimmer()
        carbsProgressLabel.startShimmer()
        fatsProgressLabel.startShimmer()

        literalProtienLabel.startShimmer()
        literalCarbsLabel.startShimmer()
        literalFatsLabel.startShimmer()
    }

    func stopShimmering() {
        caloricValueLabel.stopShimmer()
        literalKcalLabel.stopShimmer()

        proteinProgressLabel.stopShimmer()
        carbsProgressLabel.stopShimmer()
        fatsProgressLabel.stopShimmer()

        literalProtienLabel.stopShimmer()
        literalCarbsLabel.stopShimmer()
        literalFatsLabel.stopShimmer()
    }

    func addNutrient(typeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, amount: Double, consumed: Bool) async {
        logger.debug("Adding nutrient: \(typeIdentifier.rawValue), amount: \(amount), consumed: \(consumed)")
        let date = Date()
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else { return }
        let quantity = HKQuantity(unit: unit, doubleValue: amount * (consumed ? 1 : -1))
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)

        try? await HealthKitHandler.shared.healthStore.save(sample)
    }

    func addCalories(energy: Double, consumed: Bool) async {
        await addNutrient(typeIdentifier: .dietaryEnergyConsumed, unit: .kilocalorie(), amount: energy, consumed: consumed)
    }

    func addProtein(protein: Double, consumed: Bool) async {
        await addNutrient(typeIdentifier: .dietaryProtein, unit: .gram(), amount: protein, consumed: consumed)
    }

    func addCarbs(carbs: Double, consumed: Bool) async {
        await addNutrient(typeIdentifier: .dietaryCarbohydrates, unit: .gram(), amount: carbs, consumed: consumed)
    }

    func addFats(fats: Double, consumed: Bool) async {
        await addNutrient(typeIdentifier: .dietaryFatTotal, unit: .gram(), amount: fats, consumed: consumed)
    }

    func refreshStats() {
        logger.debug("Refreshing diet progress bars and caloric progress")
        prepareProgressBars([proteinProgressBar, carbsProgressBar, fatsProgressBar])

        logger.debug("Preparing caloric progress and nutrient progress bars")
        prepareCaloricProgress()

        logger.debug("Preparing nutrient progress bars")
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

    private func updateProgress(
        bar: UIProgressView?,
        label: UILabel?,
        goal: Double,
        readFunction: @escaping () async -> Double
    ) {
        Task {
            let consumed = await readFunction()
            let progress = Float(consumed / goal)

            let consumedRounded = round(consumed * 100) / 100
            let goalRounded = round(goal * 100) / 100

            DispatchQueue.main.async {
                bar?.progress = progress
                label?.text = "\(consumedRounded) / \(goalRounded)g"
            }
        }
    }

    private func prepareProgress() {
        guard let plan = MomCareUser.shared.user?.plan else { return }

        updateProgress(
            bar: proteinProgressBar,
            label: proteinProgressLabel,
            goal: plan.totalProtien,
            readFunction: { await HealthKitHandler.shared.readTotalProtein() }
        )

        updateProgress(
            bar: carbsProgressBar,
            label: carbsProgressLabel,
            goal: plan.totalCarbs,
            readFunction: { await HealthKitHandler.shared.readTotalCarbs() }
        )

        updateProgress(
            bar: fatsProgressBar,
            label: fatsProgressLabel,
            goal: plan.totalFat,
            readFunction: { await HealthKitHandler.shared.readTotalFat() }
        )
    }

    private func prepareCaloricProgress() {
        Task {
            await HealthKitHandler.shared.readCaloriesIntake { currentCaloriesIntake in
                DispatchQueue.main.async {
                    guard let dueDate = MomCareUser.shared.user?.medicalData?.dueDate,
                          let pregnancyData = Utils.pregnancyWeekAndDay(dueDate: dueDate) else { return }
                    let goal = Utils.getCaloriesGoal(trimester: pregnancyData.trimester)
                    self.animateKalcProgress(to: CGFloat(Float(currentCaloriesIntake) / Float(goal)))
                    self.caloricValueLabel.text = "\(Int(currentCaloriesIntake))/\(Int(goal))"
                }
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
