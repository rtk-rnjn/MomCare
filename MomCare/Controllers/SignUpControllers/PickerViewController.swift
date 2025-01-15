//
//  PickerViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let heights = Array(120...200) // Heights in cm from 120 to 200
    var selectedHeight: Int = 120
    
    @IBOutlet var heightPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heightPickerView.delegate = self
        heightPickerView.dataSource = self

        // Do any additional setup after loading the view.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column for height
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return heights.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(heights[row]) cm"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedHeight = heights[row]
        self.selectedHeight = selectedHeight
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SignUpYourDetailsTableViewController {
            destinationVC.updatedHeight = selectedHeight
        }
    }

    @IBAction func unwindToSignUpNoChange(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
