//
//  SignUp3TableViewController.swift
//  MomCare
//
//  Created by Nupur on 14/01/25.
//

import UIKit

class SignUp3TableViewController: UITableViewController {

    @IBOutlet weak var DueDatePopupButton: UIButton!
    @IBOutlet weak var ExistingConditionPopupButton: UIButton!
    @IBOutlet weak var FoodIntolerancePopupButton: UIButton!
    @IBOutlet weak var DietaryPreferencePopupButton: UIButton!

    @IBOutlet weak var weekPullDownButton: UIButton!
    @IBOutlet weak var dayPullDownButton: UIButton!
    @IBOutlet weak var weeksLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!

    @IBOutlet weak var secondRowCell: UITableViewCell!

    @IBOutlet weak var DueDateInputLabel: UILabel!
    @IBOutlet weak var DueDateDatePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDueDatePopUpButton()
        SetExistingConditionPopUpButton()
        SetFoodIntolerancePopUpButton()
        SetDietaryPreferencePopUpButton()

        secondRowCell.isHidden = true
        DueDateDatePicker.isHidden = true
        DueDateInputLabel.isHidden = true
        weeksLabel.isHidden = true
        weekPullDownButton.isHidden = true
        daysLabel.isHidden = true
        dayPullDownButton.isHidden = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - POPUP BUTTONS FUNCTION

    func setDueDatePopUpButton() {
        let optionClosure = { (action: UIAction) in
            print("Selected option: \(action.title)")

//            if action.title == "Estimated due date" || action.title == "Date of last menstrual period" || action.title == "Date of conception" || action.title == "Day 3 embryo transfer" || action.title == "Day 5 embryo transfer"{
//                self.secondRowCell.isHidden = false
//                self.DueDateDatePicker.isHidden = false
//                self.DueDateInputLabel.isHidden = false
//                self.DueDateInputLabel.text = action.title
//            }
//            if action.title == "Week pregnant" {
//                self.secondRowCell.isHidden = false
//                self.weeksLabel.isHidden = false
//                self.weekPullDownButton.isHidden = false
//                self.daysLabel.isHidden = false
//                self.dayPullDownButton.isHidden = false
//                
//            }
//            else {
//                self.secondRowCell.isHidden = true
//            }

            switch action.title {
            case "Estimated due date":
                self.secondRowCell.isHidden = false
                self.DueDateDatePicker.isHidden = false
                self.DueDateInputLabel.isHidden = false
                self.weeksLabel.isHidden = true
                self.weekPullDownButton.isHidden = true
                self.daysLabel.isHidden = true
                self.dayPullDownButton.isHidden = true

                self.DueDateInputLabel.text = action.title
            case "Date of last menstrual period":
                self.secondRowCell.isHidden = false
                self.DueDateDatePicker.isHidden = false
                self.DueDateInputLabel.isHidden = false
                self.weeksLabel.isHidden = true
                self.weekPullDownButton.isHidden = true
                self.daysLabel.isHidden = true
                self.dayPullDownButton.isHidden = true
                self.DueDateInputLabel.text = action.title
            case "Date of conception":
                self.secondRowCell.isHidden = false
                self.DueDateDatePicker.isHidden = false
                self.DueDateInputLabel.isHidden = false
                self.weeksLabel.isHidden = true
                self.weekPullDownButton.isHidden = true
                self.daysLabel.isHidden = true
                self.dayPullDownButton.isHidden = true
                self.DueDateInputLabel.text = action.title
            case "Day 3 embryo transfer":
                self.secondRowCell.isHidden = false
                self.DueDateDatePicker.isHidden = false
                self.DueDateInputLabel.isHidden = false
                self.weeksLabel.isHidden = true
                self.weekPullDownButton.isHidden = true
                self.daysLabel.isHidden = true
                self.dayPullDownButton.isHidden = true
                self.DueDateInputLabel.text = action.title
            case "Day 5 embryo transfer":
                self.secondRowCell.isHidden = false
                self.DueDateDatePicker.isHidden = false
                self.DueDateInputLabel.isHidden = false
                self.weeksLabel.isHidden = true
                self.weekPullDownButton.isHidden = true
                self.daysLabel.isHidden = true
                self.dayPullDownButton.isHidden = true
                self.DueDateInputLabel.text = action.title
            case "Week pregnant":
                self.secondRowCell.isHidden = false
                self.DueDateDatePicker.isHidden = true
                self.DueDateInputLabel.isHidden = true
                self.weeksLabel.isHidden = false
                self.weekPullDownButton.isHidden = false
                self.daysLabel.isHidden = false
                self.dayPullDownButton.isHidden = false

            default:
                self.secondRowCell.isHidden = true
            }

            // Ensure the table view updates its layout
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }

        // Configuring the popup button menu
        DueDatePopupButton.menu = UIMenu(children: [
            UIAction(title: "None", attributes: [.disabled], state: .on, handler: optionClosure),
            UIAction(title: "Estimated due date", handler: optionClosure),
            UIAction(title: "Date of last menstrual period", handler: optionClosure),
            UIAction(title: "Date of conception", handler: optionClosure),
            UIAction(title: "Week pregnant", handler: optionClosure),
            UIAction(title: "Day 3 embryo transfer", handler: optionClosure),
            UIAction(title: "Day 5 embryo transfer", handler: optionClosure)
        ])

        // Making the popup button interactive
        DueDatePopupButton.showsMenuAsPrimaryAction = true
        DueDatePopupButton.changesSelectionAsPrimaryAction = true
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Assuming the second row is in section 0 and index 1
        if indexPath.section == 1 && indexPath.row == 1 {
            return secondRowCell.isHidden ? 0 : UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }

    func DateOptionUpdate() {

    }

    func WeekOptionUpdate() {

    }

    func SetExistingConditionPopUpButton() {
        let optionClosure = {(action: UIAction) in print(action.title)}
        ExistingConditionPopupButton.menu = UIMenu(children: [
            UIAction(title: "None", state: .on, handler: optionClosure),
            UIAction(title: "Diabetes (Type 1, Type 2, Gestational)", handler: optionClosure),
            UIAction(title: "Hypertension", handler: optionClosure),
            UIAction(title: "Polycystic Ovary Syndrome (PCOS)", handler: optionClosure),
            UIAction(title: "Anemia", handler: optionClosure),
            UIAction(title: "Asthma", handler: optionClosure),
            UIAction(title: "Heart Disease", handler: optionClosure),
            UIAction(title: "Kidney Disease", handler: optionClosure)
        ])

        ExistingConditionPopupButton.showsMenuAsPrimaryAction = true
        ExistingConditionPopupButton.changesSelectionAsPrimaryAction = true
    }

    func SetFoodIntolerancePopUpButton() {
        let optionClosure = {(action: UIAction) in print(action.title)}
        FoodIntolerancePopupButton.menu = UIMenu(children: [
            UIAction(title: "None", state: .on, handler: optionClosure),
            UIAction(title: "Lactose Intolerance", handler: optionClosure),
            UIAction(title: "Gluten Sensitivity", handler: optionClosure),
            UIAction(title: "Egg Allergy", handler: optionClosure),
            UIAction(title: "Seafood Allergy", handler: optionClosure),
            UIAction(title: "Soy Allergy", handler: optionClosure),
            UIAction(title: "Dairy Allergy", handler: optionClosure),
            UIAction(title: "Wheat Allergy", handler: optionClosure),
            UIAction(title: "Others", handler: optionClosure)
        ])

        FoodIntolerancePopupButton.showsMenuAsPrimaryAction = true
        FoodIntolerancePopupButton.changesSelectionAsPrimaryAction = true
    }

    func SetDietaryPreferencePopUpButton() {
        let optionClosure = {(action: UIAction) in print(action.title)}
        DietaryPreferencePopupButton.menu = UIMenu(children: [
            UIAction(title: "None", attributes: [.disabled], state: .on, handler: optionClosure),
            UIAction(title: "Vegetarian", handler: optionClosure),
            UIAction(title: "Non-Vegetarian", handler: optionClosure),
            UIAction(title: "Vegan", handler: optionClosure),
            UIAction(title: "Pescatarian", handler: optionClosure),
            UIAction(title: "Flexitarian", handler: optionClosure),
            UIAction(title: "Gluten-Free", handler: optionClosure),
            UIAction(title: "Low-Carb / Ketogenic", handler: optionClosure),
            UIAction(title: "High-Protein", handler: optionClosure),
            UIAction(title: "Dairy-Free", handler: optionClosure),
            UIAction(title: "Low-Sodium", handler: optionClosure)
        ])

        DietaryPreferencePopupButton.showsMenuAsPrimaryAction = true
        DietaryPreferencePopupButton.changesSelectionAsPrimaryAction = true
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return secondRowCell.isHidden ? 1 : 2
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
