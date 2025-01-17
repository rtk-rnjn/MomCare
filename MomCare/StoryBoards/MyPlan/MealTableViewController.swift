import UIKit
struct Meal {
    var name: String
    var image: String?
    var serving: String
    var kcal: Int
}

class MealTableViewController: UITableViewController {
    
    // Sample meal data
    var breakfastMeals: [Meal] = [
        Meal(name: "Chole Chawal", image: "chole_chawal.jpg", serving: "1 serving", kcal: 350),
        Meal(name: "Aloo Paratha", image: "alu_paratha.jpg", serving: "1 serving", kcal: 250)
    ]

    var lunchMeals: [Meal] = [
        Meal(name: "Dal Tadka", image: "dal_tadka.jpg", serving: "1 serving", kcal: 300),
        Meal(name: "Veg Biryani", image: "veg_biryani.jpg", serving: "1 serving", kcal: 450)
    ]

    var sectionHeaders: [String] = ["Breakfast", "Lunch", "Snacks", "Dinner"]

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.dataSource = self
//                tableView.delegate = self
        
         // Register custom cell class
        tableView.register(MealHeaderTableViewCell.self, forCellReuseIdentifier: "MealHeaderCell")
        tableView.register(MealItemTableViewCell.self, forCellReuseIdentifier: "MealItemCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return breakfastMeals.count + 1  // +1 for header
        case 1: return lunchMeals.count + 1      // +1 for header
        default: return 1  // Adjust for snacks and dinner when adding data
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Return header cell
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "MealHeaderCell", for: indexPath) as! MealHeaderTableViewCell
//            headerCell.headerLabel.text = sectionHeaders[indexPath.section]
            
            if let headerCell = tableView.dequeueReusableCell(withIdentifier: "MealHeaderCell", for: indexPath) as? MealHeaderTableViewCell {
                
                // Use headerCell here
                return headerCell
            } else {
                // Handle the case where the cell couldn't be dequeued
                return UITableViewCell() // Or a fallback cell
            }
            
        } else {
            // Return item cell
            let mealItemCell = tableView.dequeueReusableCell(withIdentifier: "MealItemCell", for: indexPath) as! MealItemTableViewCell
            
            let meal = indexPath.section == 0 ? breakfastMeals[indexPath.row - 1] : lunchMeals[indexPath.row - 1]  // Adjusting for header
//            mealItemCell.foodImageView.image = UIImage(named: meal.image)
            if let imageName = meal.image, let image = UIImage(named: imageName) {
                mealItemCell.foodImageView.image = image
            } else {
                // Handle the case where the image is nil or not found
                mealItemCell.foodImageView?.image = UIImage(named: "Image") // or a placeholder image
                
                mealItemCell.foodImageName = "Image"
            }

            mealItemCell.mealNameLabel.text = meal.name
            mealItemCell.servingLabel.text = meal.serving
            mealItemCell.kcalLabel.text = "\(meal.kcal) Kcal"
            
            mealItemCell.updateMealItemElements()
            
            return mealItemCell
        }
    }
}
