//
//  SignUpYourDetailsTableViewController.swift
//  MomCare
//
//  Created by Batch-2 on 15/01/25.
//

import UIKit

class SignUpYourDetailsTableViewController: UITableViewController {
    
    @IBOutlet var recievedHeight: UILabel!
    @IBOutlet weak var prePregnancyWeight: UILabel!
    @IBOutlet weak var currentWeight: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    var updatedHeight: Int?
    
    @IBOutlet weak var progressView: UIProgressView!
    var initialProgress: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = initialProgress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.setProgress(0.5, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recievedHeight.text = "\(updatedHeight ?? 0) cm"
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    func presentPickerViewController(withOptions options: PickerOptions) {
        // Instantiate the picker view controller
        if let pickerVC = storyboard?.instantiateViewController(withIdentifier: "pickerView") as? PickerViewController {
            // Pass the options to the picker view controller
            pickerVC.selectedOption = options
            // Present the picker view controller modally
            pickerVC.modalPresentationStyle = .fullScreen
            self.present(pickerVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func heightButtonTapped(_ sender: Any) {
        presentPickerViewController(withOptions: .height)
    }
    
    @IBAction func prePregnancyButtonTapped(_ sender: Any) {
        presentPickerViewController(withOptions: .prePregnancyWeight)
    }
    
    @IBAction func currentWeightButtonTapped(_ sender: Any) {
        presentPickerViewController(withOptions: .currentWeight)
    }
    
    @IBAction func countryButtonTapped(_ sender: Any) {
        presentPickerViewController(withOptions: .country)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProgress" {
            // Ensure that the destination view controller is the next one
            if let destinationVC = segue.destination as? SignUpYourDetailsExtendedTableViewController {
                // Pass the current progress value (50%)
                destinationVC.initialProgress = progressView.progress
            }
        }
    }
    
    @IBAction func unwindToMainViewController(_ segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? PickerViewController {
            recievedHeight.text = "\(sourceVC.selectedHeight) cm"
        }
    }
    
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
