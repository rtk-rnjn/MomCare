//
//  SignUpExtendedTableViewController.swift
//  MomCare
//
//  Created by Nupur on 14/01/25.
//

import UIKit

class SignUpExtendedTableViewController: UITableViewController {

    // MARK: Internal

    @IBOutlet var dueDatePopupButton: UIButton!
    @IBOutlet var existingConditionPopupButton: UIButton!
    @IBOutlet var foodIntolerancePopupButton: UIButton!
    @IBOutlet var dietaryPreferencePopupButton: UIButton!
    @IBOutlet var weekPullDownButton: UIButton!
    @IBOutlet var dayPullDownButton: UIButton!
    @IBOutlet var weeksLabel: UILabel!
    @IBOutlet var daysLabel: UILabel!
    @IBOutlet var secondRowCell: UITableViewCell!
    @IBOutlet var dueDateInputLabel: UILabel!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var progressView: UIProgressView!

    var initialProgress: Float = 0.0
    var signUpDetailsTableViewController: SignUpDetailsTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = initialProgress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.progressView.setProgress(1.0, animated: true)
        }

        setupPopUpButtons()
        hideInitialElements()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return secondRowCell.isHidden ? 0 : UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        guard let signUpDetailsTableViewController else { fatalError("yeh kya hua, kaise hua... kab hua") }

        let dateOfBirth = signUpDetailsTableViewController.dateOfBirthPicker.date
        let height = signUpDetailsTableViewController.height
        let currentWeight = signUpDetailsTableViewController.currentWeight
        let prePregnancyWeight = signUpDetailsTableViewController.prePregnancyWeight

        let dueDate = dueDateDatePicker.date

        let error = height <= 0 || currentWeight <= 0 || prePregnancyWeight <= 0
        if error {
            let alert = Utils.getAlert(title: "Error", message: "Please input valid data")
            present(alert, animated: true)
            return
        }

        let userMedical = UserMedical(dateOfBirth: dateOfBirth, height: Double(height), prePregnancyWeight: Double(prePregnancyWeight), currentWeight: Double(currentWeight), dueDate: dueDate)

        MomCareUser.shared.user?.medicalData = userMedical

        Utils.save(forKey: .signedUp, withValue: true)
    }

    // MARK: Private

    private func setupPopUpButtons() {
        prepareDueDatePopUpButton()
        prepareExistingConditionPopUpButton()
        prepareFoodIntolerancePopUpButton()
        prepareDietaryPreferencePopUpButton()
    }

    private func hideInitialElements() {
        [secondRowCell, dueDateDatePicker, dueDateInputLabel, weeksLabel, weekPullDownButton, daysLabel, dayPullDownButton]
            .forEach { $0.isHidden = true }
    }

    private func prepareDueDatePopUpButton() {
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

        tableView.reloadData()
    }

    private func prepareExistingConditionPopUpButton() {
        let options = [
            "None", "Diabetes", "Hypertension", "Polycystic Ovary Syndrome", "Anemia", "Asthma", "Heart Disease", "Kidney Disease"
        ]

        configurePopUpButton(existingConditionPopupButton, options: options)
    }

    private func prepareFoodIntolerancePopUpButton() {
        let options = [
            "None", "Lactose Intolerance", "Gluten Sensitivity", "Egg Allergy", "Seafood Allergy", "Soy Allergy", "Dairy Allergy", "Wheat Allergy", "Others"

        ]
        configurePopUpButton(foodIntolerancePopupButton, options: options)
    }

    private func prepareDietaryPreferencePopUpButton() {
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

}
