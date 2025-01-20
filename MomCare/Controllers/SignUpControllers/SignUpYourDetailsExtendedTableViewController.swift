//

//  SignUpYourDetailsExtendedTableViewController.swift

//  MomCare

//

//  Created by Nupur on 14/01/25.

//

import UIKit

class SignUpYourDetailsExtendedTableViewController: UITableViewController {

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

    @IBOutlet weak var progressView: UIProgressView!

    var initialProgress: Float = 0.0

    override func viewDidLoad() {

        super.viewDidLoad()

        progressView.progress = initialProgress

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.progressView.setProgress(1.0, animated: true)

        }

        setupPopUpButtons()

        hideInitialElements()

    }

    private func setupPopUpButtons() {

        configureDueDatePopUpButton()

        configureExistingConditionPopUpButton()

        configureFoodIntolerancePopUpButton()

        configureDietaryPreferencePopUpButton()

    }

    private func hideInitialElements() {

        [secondRowCell, dueDateDatePicker, dueDateInputLabel, weeksLabel, weekPullDownButton, daysLabel, dayPullDownButton]

            .forEach { $0.isHidden = true }

    }

    private func configureDueDatePopUpButton() {

        let options = [

            "None", "Estimated due date", "Date of last menstrual period", "Date of conception", "Week pregnant", "Day 3 embryo transfer", "Day 5 embryo transfer"

        ]

        dueDatePopupButton.menu = UIMenu(children: options.map { title in

            UIAction(title: title, handler: handleDueDateOption)

        })

        dueDatePopupButton.showsMenuAsPrimaryAction = true

        dueDatePopupButton.changesSelectionAsPrimaryAction = true

    }

        private func handleDueDateOption(_ action: UIAction) {

            let showPicker = [

                "Estimated due date", "Date of last menstrual period", "Date of conception", "Day 3 embryo transfer", "Day 5 embryo transfer"

            ].contains(action.title)

            let showWeeks = action.title == "Week pregnant"

            secondRowCell.isHidden = !showPicker && !showWeeks

            dueDateDatePicker.isHidden = !showPicker

            dueDateInputLabel.isHidden = !showPicker

            weeksLabel.isHidden = !showWeeks

            weekPullDownButton.isHidden = !showWeeks

            daysLabel.isHidden = !showWeeks

            dayPullDownButton.isHidden = !showWeeks

            dueDateInputLabel.text = action.title

            tableView.beginUpdates()

            tableView.endUpdates()

        }

        private func configureExistingConditionPopUpButton() {

            let options = [

                "None", "Diabetes (Type 1, Type 2, Gestational)", "Hypertension", "Polycystic Ovary Syndrome (PCOS)", "Anemia", "Asthma", "Heart Disease", "Kidney Disease"

            ]

            configurePopUpButton(existingConditionPopupButton, options: options)

        }

        private func configureFoodIntolerancePopUpButton() {

            let options = [

                "None", "Lactose Intolerance", "Gluten Sensitivity", "Egg Allergy", "Seafood Allergy", "Soy Allergy", "Dairy Allergy", "Wheat Allergy", "Others"

            ]

            configurePopUpButton(foodIntolerancePopupButton, options: options)

        }

        private func configureDietaryPreferencePopUpButton() {

            let options = [

                "None", "Vegetarian", "Non-Vegetarian", "Vegan", "Pescatarian", "Flexitarian", "Gluten-Free", "Low-Carb / Ketogenic", "High-Protein", "Dairy-Free", "Low-Sodium"

            ]

            configurePopUpButton(dietaryPreferencePopupButton, options: options)

        }

        private func configurePopUpButton(_ button: UIButton, options: [String]) {

            button.menu = UIMenu(children: options.map { title in

                UIAction(title: title, handler: { action in

                    print("Selected option: \(action.title)")

                })

            })

            button.showsMenuAsPrimaryAction = true

            button.changesSelectionAsPrimaryAction = true

        }

        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            // second row is in section 1, index 1

            if indexPath.section == 1 && indexPath.row == 1 {

                return secondRowCell.isHidden ? 0 : UITableView.automaticDimension

            }

            return UITableView.automaticDimension

        }

}
