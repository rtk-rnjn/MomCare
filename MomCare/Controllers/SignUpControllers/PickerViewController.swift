//
//  PickerViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

public enum PickerOptions {
    case height
    case prePregnancyWeight
    case currentWeight
    case country
}

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Lifecycle

    init?(coder: NSCoder, with selectedOption: PickerOptions, sender tableViewController: SignUpDetailsTableViewController) {
        self.selectedOption = selectedOption
        signUpDetailsTableViewController = tableViewController
        super.init(coder: coder)

        preparePickerView()
    }

    init?(coder: NSCoder, with textField: UITextField, sender tableViewController: SignUpTableViewController) {
        signUpTableViewController = tableViewController

        super.init(coder: coder)
        preparePickerView(with: textField)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let heights: Array = .init(120...200)
    let weight: Array = .init(30...200)

    @IBOutlet var pickerView: UIPickerView!

    var selectedOption: PickerOptions!
    var currentOptions: [Any] = []

    var countryNames: [String] = []
    var countryCodes: [String] = []
    var suffix: String = ""

    var signUpDetailsTableViewController: SignUpDetailsTableViewController!
    var signUpTableViewController: SignUpTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var label = "\(currentOptions[row]) \(suffix)"
        label = label.trimmingCharacters(in: .whitespaces)
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch selectedOption {
        case .height:
            signUpDetailsTableViewController.heightLabel.text = "\(currentOptions[row]) \(suffix)"
            if let height = currentOptions[row] as? Int {
                signUpDetailsTableViewController.height = height
            }

        case .prePregnancyWeight:
            signUpDetailsTableViewController.prePregnancyWeightLabel.text = "\(currentOptions[row]) \(suffix)"
            if let weight = currentOptions[row] as? Int {
                signUpDetailsTableViewController.prePregnancyWeight = weight
            }

        case .currentWeight:
            signUpDetailsTableViewController.currentWeightLabel.text = "\(currentOptions[row]) \(suffix)"
            if let weight = currentOptions[row] as? Int {
                signUpDetailsTableViewController.currentWeight = weight
            }

        case .country:
            signUpDetailsTableViewController.countryLabel.text = "\(currentOptions[row])"
        case .none:
            signUpTableViewController.countryCodeField.text = "\(currentOptions[row])"
        }
    }

    // MARK: Private

    private func preparePickerView() {
        switch selectedOption {
        case .height:
            currentOptions = heights
            suffix = "cm"

        case .prePregnancyWeight:
            currentOptions = weight
            suffix = "kg"

        case .currentWeight:
            currentOptions = weight
            suffix = "kg"

        case .country:
            currentOptions = CountryData.countryCodes.values.map { $0 }
            suffix = ""

        case .none:
            fatalError("tune o rangile kaisa jadu kiya 🎶")
        }
    }

    private func preparePickerView(with textField: UITextField) {
        currentOptions = CountryData.countryCodes.keys.map { return "+\($0)" }
    }

}
