import UIKit

class DietTableViewController: UITableViewController {
    @IBOutlet var dietTableView: UITableView!

    var dietViewController: DietViewController

    private var mealNames = ["Breakfast", "Lunch", "Snacks", "Dinner"]
    private var foodData: [[FoodItem]] = []

    private func getFoods(with indexPath: IndexPath) -> FoodItem {
        return foodData[indexPath.section][indexPath.row - 1]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        foodData = [
            MomCareUser.shared.diet.meals[.breakfast] ?? [],
            MomCareUser.shared.diet.meals[.lunch] ?? [],
            MomCareUser.shared.diet.meals[.snacks] ?? [],
            MomCareUser.shared.diet.meals[.dinner] ?? []
        ]
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

    init?(coder: NSCoder, dietViewController: DietViewController) {
        self.dietViewController = dietViewController
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return foodData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let foods = foodData[section]
        return foods.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? HeaderTableViewCell
            guard let cell else { fatalError("'HeaderCell' not found") }
            cell.updateTitle(with: mealNames[indexPath.section], at: indexPath.section, of: self)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentTableViewCell
        guard let cell else { fatalError("'ContentCell' not found") }

        let foodItem = getFoods(with: indexPath)
        cell.updateElements(with: foodItem, at: indexPath, of: self)

        return cell
    }

    func performSegueToSearch(with: Any?) {
        performSegue(withIdentifier: "segueShowSearchViewController", sender: nil)
    }

    @IBAction func unwindToMyPlanDiet(_ segue: UIStoryboardSegue) {
    }
}
