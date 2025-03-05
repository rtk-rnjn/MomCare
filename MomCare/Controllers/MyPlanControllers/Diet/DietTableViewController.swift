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
            guard let foods = getFoods(with: indexPath) else { fatalError() }
            let allConsumed = foods.allSatisfy { $0.consumed }

            cell.updateElements(with: mealNames[indexPath.section], segueHandler: performSegueToSearch, refreshHandler: refreshHandler, allConsumed: allConsumed) {
                for foodItem in foods {
                    let shouldConsume = allConsumed ? foodItem.consumed : !foodItem.consumed
                    if shouldConsume {
                        DietViewController.addCalories(energy: Double(foodItem.calories), consumed: !allConsumed)
                        DietViewController.addCarbs(carbs: Double(foodItem.carbs), consumed: !allConsumed)
                        DietViewController.addProtein(protein: Double(foodItem.protein), consumed: !allConsumed)
                        DietViewController.addFats(fats: Double(foodItem.fat), consumed: !allConsumed)
                    }
                }


                switch indexPath.section {
                case 0:
                    MomCareUser.shared.markFoodsAsConsumed(in: .breakfast, consumed: !allConsumed)

                case 1:
                    MomCareUser.shared.markFoodsAsConsumed(in: .lunch, consumed: !allConsumed)

                case 2:
                    MomCareUser.shared.markFoodsAsConsumed(in: .snacks, consumed: !allConsumed)

                case 3:
                    MomCareUser.shared.markFoodsAsConsumed(in: .dinner, consumed: !allConsumed)

                default:
                    fatalError()
                }

                return !allConsumed
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

    func performSegueToSearch(_ sender: Any?) {
        performSegue(withIdentifier: "segueShowSearchViewController", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowSearchViewController" {
            let navigationController = segue.destination as? UINavigationController
            let searchViewController = navigationController?.topViewController as? SearchViewController
            searchViewController?.refreshHandler = refreshHandler
            searchViewController?.mealName = sender as? String
        }
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

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == 0 {
            return nil
        }

        if let foods = getFoods(with: indexPath), foods[indexPath.row - 1].consumed {
            return nil
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                switch indexPath.section {
                case 0: MomCareUser.shared.user?.plan.breakfast.remove(at: indexPath.row - 1)
                case 1: MomCareUser.shared.user?.plan.lunch.remove(at: indexPath.row - 1)
                case 2: MomCareUser.shared.user?.plan.snacks.remove(at: indexPath.row - 1)
                case 3: MomCareUser.shared.user?.plan.dinner.remove(at: indexPath.row - 1)
                default: fatalError()
                }
                self.tableView.reloadData()
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }
}
