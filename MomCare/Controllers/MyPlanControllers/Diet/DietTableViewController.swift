import UIKit

class DietTableViewController: UITableViewController {

    // MARK: Internal

    var dietViewController: DietViewController?

    final var proteinGoal: Double {
        return Double(ContentHandler.shared.plan?.allMeals().reduce(0) { $0 + $1.protein } ?? 0)
    }

    final var carbsGoal: Double {
        return Double(ContentHandler.shared.plan?.allMeals().reduce(0) { $0 + $1.carbs } ?? 0)
    }

    final var fatsGoal: Double {
        return Double(ContentHandler.shared.plan?.allMeals().reduce(0) { $0 + $1.fat } ?? 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            if let user = MomCareUser.shared.user, let medical = user.medicalData {
                if user.plan.isEmpty() || user.plan.isOutdated() {
                    let meals = await ContentHandler.shared.fetchPlan(from: medical)
                    MomCareUser.shared.user?.plan = meals
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "HeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        tableView.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")

        tableView.showsVerticalScrollIndicator = false
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

                MomCareUser.shared.markFoodsAsConsumed(in: MealType(rawValue: indexPath.section)!, consumed: !allConsumed)
                return !allConsumed
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentTableViewCell
        guard let cell else { fatalError("'ContentCell' not found") }

        guard let foodItems = getFoods(with: indexPath) else { return cell }
        let food = foodItems[indexPath.row - 1]
        cell.updateElements(with: food, refreshHandler: refreshHandler) {
            return MomCareUser.shared.toggleConsumed(for: food, in: MealType(rawValue: indexPath.section)!)!
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowSearchViewController" {
            let navigationController = segue.destination as? UINavigationController
            let searchViewController = navigationController?.topViewController as? SearchViewController
            searchViewController?.mealName = sender as? String
            searchViewController?.completionHandlerOnFoodItemAdd = {
                self.refreshHandler()
            }
        }
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

    func performSegueToSearch(_ sender: Any?) {
        performSegue(withIdentifier: "segueShowSearchViewController", sender: sender)
    }

    @IBAction func unwindToMyPlanDiet(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private var mealNames = ["Breakfast", "Lunch", "Snacks", "Dinner"]

    private func getFoods(with indexPath: IndexPath) -> [FoodItem]? {
        return MomCareUser.shared.user?.plan[indexPath.section]
    }

    private func refreshHandler() {
        tableView.reloadData()
        dietViewController?.refresh()
    }

}
