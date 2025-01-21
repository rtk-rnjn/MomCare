//
//  PickerViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let heights = Array(120...200)
    let weight = Array(30...200)

    var selectedHeight: Int = 120
    var selectedCountry: String = ""

    @IBOutlet var pickerView: UIPickerView!

    var selectedOption: PickerOptions?

    var currentOptions: [Any] = []

    var suffix: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self

        switch selectedOption {
        case .height: 
            currentOptions = heights
            suffix = "cm"

        case .prePregnancyWeight: 
            currentOptions = weight
            suffix = "Kg"

        case .currentWeight: 
            currentOptions = weight
            suffix = "Kg"

        case .country: 
            currentOptions = countryList
            suffix = ""

        case .none: 
            break
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let heightValue = currentOptions[row] as? Int {
            return "\(heightValue) \(suffix)"
        } else if let countryValue = currentOptions[row] as? String {
            return countryValue
        }

        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let heightValue = currentOptions[row] as? Int {
            selectedHeight = heightValue
        } else if let countryValue = currentOptions[row] as? String {
            selectedCountry = countryValue
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SignUpYourDetailsTableViewController {
            destinationVC.updatedHeight = selectedHeight
        }
    }
}
