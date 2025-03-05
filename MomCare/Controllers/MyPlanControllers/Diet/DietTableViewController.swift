import UIKit

class DietTableViewController: UITableViewController {

    // MARK: Lifecycle

    init?(coder: NSCoder, dietViewController: DietViewController) {
        self.dietViewController = dietViewController
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    @IBOutlet var dietTableView: UITableView!

    var dietViewController: DietViewController

    var proteinGoal: Double {
        return Double(SampleFoodData.uniqueFoodItems.reduce(0) { $0 + $1.protein })
    }

    var carbsGoal: Double {
        return Double(SampleFoodData.uniqueFoodItems.reduce(0) { $0 + $1.carbs })
    }

    var fatsGoal: Double {
        return Double(SampleFoodData.uniqueFoodItems.reduce(0) { $0 + $1.fat })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dietTableView.register(UINib(nibName: "HeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        dietTableView.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")

        dietTableView.delegate = self
        dietTableView.dataSource = self

        dietTableView.showsVerticalScrollIndicator = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let foods = getFoods(with: IndexPath(row: 0, section: section)) {
            return foods.count + 1
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? HeaderTableViewCell
            guard let cell else { fatalError("'HeaderCell' not found") }
            let foods = getFoods(with: indexPath)
            let allConsumed = foods?.allSatisfy { $0.consumed }

            cell.updateElements(with: mealNames[indexPath.section], segueHandler: performSegueToSearch, refreshHandler: refreshHandler, allConsumed: allConsumed!) {
                if !allConsumed! {
                    for foodItem in foods! {
                        if !foodItem.consumed {
                            DietViewController.addCalories(energy: Double(foodItem.calories), consumed: true)
                            DietViewController.addCarbs(carbs: Double(foodItem.carbs), consumed: true)
                            DietViewController.addProtein(protein: Double(foodItem.protein), consumed: true)
                            DietViewController.addFats(fats: Double(foodItem.fat), consumed: true)
                        }
                    }
                } else {
                    for foodItem in foods! {
                        if foodItem.consumed {
                            DietViewController.addCalories(energy: Double(foodItem.calories), consumed: false)
                            DietViewController.addCarbs(carbs: Double(foodItem.carbs), consumed: false)
                            DietViewController.addProtein(protein: Double(foodItem.protein), consumed: false)
                            DietViewController.addFats(fats: Double(foodItem.fat), consumed: false)
                        }
                    }
                }

                switch indexPath.section {
                case 0:
                    MomCareUser.shared.markFoodsAsConsumed(in: .breakfast, consumed: !allConsumed!)
                    return !allConsumed!

                case 1:
                    MomCareUser.shared.markFoodsAsConsumed(in: .lunch, consumed: !allConsumed!)
                    return !allConsumed!

                case 2:
                    MomCareUser.shared.markFoodsAsConsumed(in: .snacks, consumed: !allConsumed!)
                    return !allConsumed!

                case 3:
                    MomCareUser.shared.markFoodsAsConsumed(in: .dinner, consumed: !allConsumed!)
                    return !allConsumed!

                default:
                    fatalError()
                }
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentTableViewCell
        guard let cell else { fatalError("'ContentCell' not found") }

        guard let foodItems = getFoods(with: indexPath) else { return cell }
        let food = foodItems[indexPath.row - 1]
        cell.updateElements(with: food, refreshHandler: refreshHandler) {
            switch indexPath.section {
            case 0:
                return MomCareUser.shared.toggleConsumed(for: food, in: .breakfast)!
            case 1:
                return MomCareUser.shared.toggleConsumed(for: food, in: .lunch)!
            case 2:
                return MomCareUser.shared.toggleConsumed(for: food, in: .snacks)!
            case 3:
                return MomCareUser.shared.toggleConsumed(for: food, in: .dinner)!
            default:
                fatalError()
            }
        }

        return cell
    }

    func performSegueToSearch() {
        performSegue(withIdentifier: "segueShowSearchViewController", sender: nil)
    }

    @IBAction func unwindToMyPlanDiet(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private var mealNames = ["Breakfast", "Lunch", "Snacks", "Dinner"]

    private func getFoods(with indexPath: IndexPath) -> [FoodItem]? {
        switch indexPath.section {
        case 0:
            return MomCareUser.shared.user?.plan.breakfast
        case 1:
            return MomCareUser.shared.user?.plan.lunch
        case 2:
            return MomCareUser.shared.user?.plan.snacks
        case 3:
            return MomCareUser.shared.user?.plan.dinner
        default:
            fatalError()
        }
    }

    private func refreshHandler() {
        tableView.reloadData()
        dietViewController.refresh()
    }
}
