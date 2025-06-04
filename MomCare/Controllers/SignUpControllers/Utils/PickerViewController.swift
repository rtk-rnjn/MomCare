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

    var options: [String: String] = [:]
    var completionHandler: ((String, String) -> Void)?

    private var sortedOptions: [(key: String, value: String)] = []
    private var selectedOption: (key: String, value: String)?

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self

        if options.isEmpty {
            fatalError("Options not set")
        }

        sortedOptions = sortOptions(options)
        let defaultRow = defaultIndex(in: sortedOptions)
        pickerView.selectRow(defaultRow, inComponent: 0, animated: false)

        let defaultOption = sortedOptions[defaultRow]
        selectedOption = defaultOption
        completionHandler?(defaultOption.key, defaultOption.value)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortedOptions[row].value
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = sortedOptions[row]
        selectedOption = selected
        completionHandler?(selected.key, selected.value)
    }

    private func sortOptions(_ dict: [String: String]) -> [(key: String, value: String)] {
        let isNumeric = dict.keys.allSatisfy { Int($0) != nil }
        if isNumeric {
            return dict.sorted { Int($0.key)! < Int($1.key)! }
        } else {
            return dict.sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
        }
    }

    private func defaultIndex(in sorted: [(key: String, value: String)]) -> Int {
        return 0
    }
}
