import UIKit
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.DietTableViewController", category: "ViewController")

class DietTableViewController: UITableViewController {

    // MARK: Internal

    var dietViewController: DietViewController?
    var dataFetched: Bool = false

    final var proteinGoal: Double {
        return sumNutrition(\.protein)
    }

    final var carbsGoal: Double {
        return sumNutrition(\.carbs)
    }

    final var fatsGoal: Double {
        return sumNutrition(\.fat)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlan()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        logger.debug("All cells registered successfully")

        tableView.showsVerticalScrollIndicator = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if !dataFetched {
            return 4
        }

        return mealNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !dataFetched {
            return 2
        }

        return (getFoods(with: IndexPath(row: 0, section: section))?.count ?? 0) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return indexPath.row == 0 ? headerCell(for: indexPath) : contentCell(for: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowSearchViewController" {
            prepareSearchSegue(segue, sender: sender)
        }
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return contextMenu(for: indexPath)
    }

    func performSegueToSearch(_ sender: Any?) {
        performSegue(withIdentifier: "segueShowSearchViewController", sender: sender)
    }

    @IBAction func unwindToMyPlanDiet(_ segue: UIStoryboardSegue) {}

    // MARK: Private

    private let mealNames = ["Breakfast", "Lunch", "Snacks", "Dinner"]

    private func sumNutrition(_ keyPath: KeyPath<FoodItem, Double>) -> Double {
        return Double(ContentHandler.shared.plan?.allMeals().reduce(0) { $0 + $1[keyPath: keyPath] } ?? 0)
    }

    private func registerCells() {
        tableView.register(UINib(nibName: "HeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        tableView.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
    }

    private func updatePlan() {
        if !dataFetched {
            dietViewController?.startShimmering()
        }

        Task {
            guard let user = MomCareUser.shared.user, let medical = user.medicalData else {
                logger.error("User or medical data not found")
                return
            }

            if user.plan.isEmpty() || user.plan.isOutdated() {
                logger.debug("Fetching new plan for user: \(user.emailAddress)")
                let meals = await ContentHandler.shared.fetchPlan(from: medical)
                MomCareUser.shared.user?.plan = meals
            }

            DispatchQueue.main.async {
                self.dataFetched = true
                self.dietViewController?.myPlanViewController?.dietsLoaded = true
                self.dietViewController?.stopShimmering()
                self.tableView.reloadData()
            }
        }
    }

    private func getFoods(with indexPath: IndexPath) -> [FoodItem]? {
        return MomCareUser.shared.user?.plan[indexPath.section]
    }

    private func headerCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? HeaderTableViewCell else {
            fatalError("'HeaderCell' not found")
        }

        cell.mealHeaderLabel.startShimmer()

        if !dataFetched {
            return cell
        }
        cell.mealHeaderLabel.stopShimmer()

        guard let foods = getFoods(with: indexPath) else {
            fatalError()
        }

        let allConsumed = foods.allSatisfy { $0.consumed }

        cell.updateElements(
            with: mealNames[indexPath.section],
            segueHandler: performSegueToSearch,
            allConsumed: allConsumed
        ) {
            await self.toggleConsumption(for: foods, in: indexPath.section, allConsumed: allConsumed)
            return !allConsumed
        }
        cell.refreshHandler = {
            let section = indexPath.section
            let numberOfFoods = (self.getFoods(with: IndexPath(row: 0, section: section))?.count ?? 0) + 1
            let indexPaths = (0..<numberOfFoods).map { IndexPath(row: $0, section: section) }
            self.refreshHandler(with: indexPaths)
        }

        return cell
    }

    private func toggleConsumption(for foods: [FoodItem], in section: Int, allConsumed: Bool) async {
        for foodItem in foods {
            let shouldConsume = allConsumed ? foodItem.consumed : !foodItem.consumed
            if shouldConsume {
                await dietViewController?.addCalories(energy: Double(foodItem.calories), consumed: !allConsumed)
                await dietViewController?.addCarbs(carbs: Double(foodItem.carbs), consumed: !allConsumed)
                await dietViewController?.addProtein(protein: Double(foodItem.protein), consumed: !allConsumed)
                await dietViewController?.addFats(fats: Double(foodItem.fat), consumed: !allConsumed)
            }
        }

        MomCareUser.shared.markFoodsAsConsumed(in: MealType(rawValue: section)!, consumed: !allConsumed)
    }

    private func contentCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentTableViewCell else {
            fatalError("'ContentCell' not found")
        }

        cell.foodImageView.startShimmer()
        cell.foodItemLabel.startShimmer()
        cell.kalcLabel.startShimmer()
        cell.qualtityLabel.startShimmer()
        if !dataFetched {
            return cell
        }
        cell.qualtityLabel.stopShimmer()
        cell.kalcLabel.stopShimmer()
        cell.foodItemLabel.stopShimmer()
        cell.foodImageView.stopShimmer()

        guard let foodItems = getFoods(with: indexPath) else { return cell }
        let food = foodItems[indexPath.row - 1]

        cell.updateElements(with: food) {
            guard let meal = MealType(rawValue: indexPath.section) else { return false }
            return MomCareUser.shared.toggleConsumed(for: food, in: meal) ?? false
        }
        cell.dietViewController = dietViewController
        cell.refreshHandler = {
            self.refreshHandler(with: [indexPath])
        }
        return cell
    }

    private func prepareSearchSegue(_ segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as? UINavigationController
        let searchViewController = navigationController?.topViewController as? SearchViewController
        searchViewController?.mealName = sender as? String
        searchViewController?.completionHandlerOnFoodItemAdd = {
            self.refreshHandler()
        }
    }

    private func contextMenu(for indexPath: IndexPath) -> UIContextMenuConfiguration? {
        guard indexPath.row != 0,
              let foods = getFoods(with: indexPath),
              !foods[indexPath.row - 1].consumed else {
            return nil
        }

        let previewProvider = previewProvider(for: indexPath)
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { _ in
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteFood(at: indexPath)
                self.tableView.reloadData()
            }

            return UIMenu(title: "", children: [deleteAction])
        }
    }

    private func previewProvider(for indexPath: IndexPath) -> UIContextMenuContentPreviewProvider? {
        guard let foods = getFoods(with: indexPath), !foods.isEmpty else { return nil }
        let foodItem = foods[indexPath.row - 1]
        let foodDetailsViewController = FoodDetailsViewController(foodItem: foodItem)

        return {
            foodDetailsViewController
        }
    }

    private func deleteFood(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0: MomCareUser.shared.user?.plan.breakfast.remove(at: indexPath.row - 1)
        case 1: MomCareUser.shared.user?.plan.lunch.remove(at: indexPath.row - 1)
        case 2: MomCareUser.shared.user?.plan.snacks.remove(at: indexPath.row - 1)
        case 3: MomCareUser.shared.user?.plan.dinner.remove(at: indexPath.row - 1)
        default: fatalError()
        }
    }

    private func refreshHandler(with indexPaths: [IndexPath]? = nil) {
        logger.debug("Refreshing diet table view data")
        if let indexPaths {
            tableView.reloadRows(at: indexPaths, with: .automatic)
        } else {
            tableView.reloadData()
        }
        dietViewController?.refreshStats()
    }
}
