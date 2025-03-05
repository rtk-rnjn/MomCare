//
//  PickerViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Internal

    @IBOutlet var pickerView: UIPickerView!

    // Value: Display Name
    var options: [String: String] = [:]
    var completionHandler: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self

        if options.isEmpty {
            fatalError("Options not set")
        }

        let sortedOptions = options.sorted {
            if let firstNumber = Int($0.key), let secondNumber = Int($1.key) {
                return firstNumber < secondNumber
            }

            return $0.value < $1.value
        }
        let selectedOption = sortedOptions[0]
        self.selectedOption = selectedOption
        pickerView.selectRow(0, inComponent: 0, animated: false)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let sortedOptionsByAlphabet = options.sorted { $0.value < $1.value }
        return sortedOptionsByAlphabet[row].value
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sortedOptionsByAlphabet = options.sorted { $0.value < $1.value }
        let selectedOption = sortedOptionsByAlphabet[row]

        self.selectedOption = selectedOption

        completionHandler?(selectedOption.key, selectedOption.value)
    }

    // MARK: Private

    private var selectedOption: (key: String, value: String)?
}
