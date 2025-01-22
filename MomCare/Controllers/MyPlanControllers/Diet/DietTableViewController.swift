import UIKit

class DietTableViewController: UITableViewController {
    
    @IBOutlet var dietTableView: UITableView!

    private var mealNames = ["Breakfast", "Lunch", "Snacks", "Dinner"]
    private var foodData: [[FoodItem]] = []

    private func getFoods(with indexPath: IndexPath) -> FoodItem {
        return foodData[indexPath.section][indexPath.row - 1]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        foodData = [
            MomCareUser.shared.diet.breakfast,
            MomCareUser.shared.diet.lunch,
            MomCareUser.shared.diet.snacks,
            MomCareUser.shared.diet.dinner
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return foodData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let foods = foodData[section]
        return foods.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderTableViewCell
            cell.updateTitle(with: mealNames[indexPath.section], at: indexPath.section)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentTableViewCell
        guard let cell = cell else { fatalError() }
        
        let foodItem = getFoods(with: indexPath)
        cell.updateElements(with: foodItem, at: indexPath)
        
        return cell
    }
}
