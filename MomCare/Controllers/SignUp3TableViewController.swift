//
//  SignUp3TableViewController.swift
//  MomCare
//
//  Created by Nupur on 14/01/25.
//

import UIKit

class SignUp3TableViewController: UITableViewController {

    @IBOutlet weak var dueDatePopupButton: UIButton!
    @IBOutlet weak var existingConditionPopupButton: UIButton!
    @IBOutlet weak var foodIntolerancePopupButton: UIButton!
    @IBOutlet weak var dietaryPreferencePopupButton: UIButton!

    @IBOutlet weak var weekPullDownButton: UIButton!
    @IBOutlet weak var dayPullDownButton: UIButton!
    @IBOutlet weak var weeksLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!

    @IBOutlet weak var secondRowCell: UITableViewCell!

    @IBOutlet weak var dueDateInputLabel: UILabel!
    @IBOutlet weak var dueDateDatePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDueDatePopUpButton()
        setExistingConditionPopUpButton()
        setFoodIntolerancePopUpButton()
        setDietaryPreferencePopUpButton()

        secondRowCell.isHidden = true
        dueDateDatePicker.isHidden = true
        dueDateInputLabel.isHidden = true
        weeksLabel.isHidden = true
        weekPullDownButton.isHidden = true
        daysLabel.isHidden = true
        dayPullDownButton.isHidden = true

        func setDueDatePopUpButton() {
            let optionClosure = { (action: UIAction) in
                print("Selected option: \(action.title)")

                switch action.title {
                case "Estimated due date":
                    self.secondRowCell.isHidden = false
                    self.dueDateDatePicker.isHidden = false
                    self.dueDateInputLabel.isHidden = false
                    self.weeksLabel.isHidden = true
                    self.weekPullDownButton.isHidden = true
                    self.daysLabel.isHidden = true
                    self.dayPullDownButton.isHidden = true

                    self.dueDateInputLabel.text = action.title
                case "Date of last menstrual period":
                    self.secondRowCell.isHidden = false
                    self.dueDateDatePicker.isHidden = false
                    self.dueDateInputLabel.isHidden = false
                    self.weeksLabel.isHidden = true
                    self.weekPullDownButton.isHidden = true
                    self.daysLabel.isHidden = true
                    self.dayPullDownButton.isHidden = true
                    self.dueDateInputLabel.text = action.title
                case "Date of conception":
                    self.secondRowCell.isHidden = false
                    self.dueDateDatePicker.isHidden = false
                    self.dueDateInputLabel.isHidden = false
                    self.weeksLabel.isHidden = true
                    self.weekPullDownButton.isHidden = true
                    self.daysLabel.isHidden = true
                    self.dayPullDownButton.isHidden = true
                    self.dueDateInputLabel.text = action.title
                case "Day 3 embryo transfer":
                    self.secondRowCell.isHidden = false
                    self.dueDateDatePicker.isHidden = false
                    self.dueDateInputLabel.isHidden = false
                    self.weeksLabel.isHidden = true
                    self.weekPullDownButton.isHidden = true
                    self.daysLabel.isHidden = true
                    self.dayPullDownButton.isHidden = true
                    self.dueDateInputLabel.text = action.title
                case "Day 5 embryo transfer":
                    self.secondRowCell.isHidden = false
                    self.dueDateDatePicker.isHidden = false
                    self.dueDateInputLabel.isHidden = false
                    self.weeksLabel.isHidden = true
                    self.weekPullDownButton.isHidden = true
                    self.daysLabel.isHidden = true
                    self.dayPullDownButton.isHidden = true
                    self.dueDateInputLabel.text = action.title
                case "Week pregnant":
                    self.secondRowCell.isHidden = false
                    self.dueDateDatePicker.isHidden = true
                    self.dueDateInputLabel.isHidden = true
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
            dueDatePopupButton.menu = UIMenu(children: [
                UIAction(title: "None", attributes: [.disabled], state: .on, handler: optionClosure),
                UIAction(title: "Estimated due date", handler: optionClosure),
                UIAction(title: "Date of last menstrual period", handler: optionClosure),
                UIAction(title: "Date of conception", handler: optionClosure),
                UIAction(title: "Week pregnant", handler: optionClosure),
                UIAction(title: "Day 3 embryo transfer", handler: optionClosure),
                UIAction(title: "Day 5 embryo transfer", handler: optionClosure)
            ])

            // Making the popup button interactive
            dueDatePopupButton.showsMenuAsPrimaryAction = true
            dueDatePopupButton.changesSelectionAsPrimaryAction = true
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // Assuming the second row is in section 0 and index 1
            if indexPath.section == 1 && indexPath.row == 1 {
                return secondRowCell.isHidden ? 0 : UITableView.automaticDimension
            }
            return UITableView.automaticDimension
        }

        func dateOptionUpdate() {

        }

        func weekOptionUpdate() {

        }

        func setExistingConditionPopUpButton() {
            let optionClosure = {(action: UIAction) in print(action.title)}
            existingConditionPopupButton.menu = UIMenu(children: [
                UIAction(title: "None", state: .on, handler: optionClosure),
                UIAction(title: "Diabetes (Type 1, Type 2, Gestational)", handler: optionClosure),
                UIAction(title: "Hypertension", handler: optionClosure),
                UIAction(title: "Polycystic Ovary Syndrome (PCOS)", handler: optionClosure),
                UIAction(title: "Anemia", handler: optionClosure),
                UIAction(title: "Asthma", handler: optionClosure),
                UIAction(title: "Heart Disease", handler: optionClosure),
                UIAction(title: "Kidney Disease", handler: optionClosure)
            ])

            existingConditionPopupButton.showsMenuAsPrimaryAction = true
            existingConditionPopupButton.changesSelectionAsPrimaryAction = true
        }

        func setFoodIntolerancePopUpButton() {
            let optionClosure = {(action: UIAction) in print(action.title)}
            foodIntolerancePopupButton.menu = UIMenu(children: [
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

            foodIntolerancePopupButton.showsMenuAsPrimaryAction = true
            foodIntolerancePopupButton.changesSelectionAsPrimaryAction = true
        }

        func setDietaryPreferencePopUpButton() {
            let optionClosure = {(action: UIAction) in print(action.title)}
            dietaryPreferencePopupButton.menu = UIMenu(children: [
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

            dietaryPreferencePopupButton.showsMenuAsPrimaryAction = true
            dietaryPreferencePopupButton.changesSelectionAsPrimaryAction = true
        }

    }
}
