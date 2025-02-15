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
    @IBOutlet var weekPullDownButton: UIButton!
    @IBOutlet var dayPullDownButton: UIButton!
    @IBOutlet var weeksLabel: UILabel!
    @IBOutlet var daysLabel: UILabel!
    @IBOutlet var secondRowCell: UITableViewCell!
    @IBOutlet var dueDateInputLabel: UILabel!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var progressView: UIProgressView!

    var initialProgress: Float = 0.0
    var userMedical: UserMedical?

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController, let presentationController = destination.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium()]
            if let medicalDetailSelectorTableViewController = destination.viewControllers.first as? MultipleSelectorTableViewController {
                medicalDetailSelectorTableViewController.options = sender as? [String] ?? []
            }
        }
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        let dueDate = dueDateDatePicker.date
        
        userMedical?.dueDate = dueDate
        MomCareUser.shared.user?.medicalData = userMedical

        Utils.save(forKey: .signedUp, withValue: true)

        performSegue(withIdentifier: "segueShowInitialTabBarController", sender: nil)
    }

    @IBAction func intoleranceButtonTapped(_ sender: Any) {
        let options = Intolerance.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: options)
    }

    @IBAction func preExistingConditionTapped(_ sender: Any) {
        let options = PreExistingCondition.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: options)
    }

    @IBAction func dietaryPreferenceTapped(_ sender: Any) {
        let options = DietaryPreference.allCases.map { $0.rawValue }
        performSegue(withIdentifier: "segueShowMedicalDetailSelectorTableViewController", sender: options)
    }

    // MARK: Private

    private func setupPopUpButtons() {
        prepareDueDatePopUpButton()
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

    private func configurePopUpButton(_ button: UIButton, options: [String]) {
        button.menu = UIMenu(children: options.map { title in
            UIAction(title: title, handler: { action in
                print("Selected option: \(action.title)")
            })
        })
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
    }
    
    @IBAction func unwinToMedicalDetail(_ segue: UIStoryboardSegue) {
        print(segue.identifier)
    }

}
