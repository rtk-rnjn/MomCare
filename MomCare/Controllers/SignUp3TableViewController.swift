//
//  SignUp3TableViewController.swift
//  MomCare
//
//  Created by Nupur on 14/01/25.
//

import UIKit

class SignUp3TableViewController: UITableViewController {

    
    @IBOutlet weak var DueDatePopupButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetDueDatePopUpButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: - POPUP BUTTONS FUNCTION
    
    func SetDueDatePopUpButton(){
        let optionClosure = {(action: UIAction) in print(action.title)}
        DueDatePopupButton.menu = UIMenu(children : [
            UIAction(title : "None", attributes: [.disabled], state :.on , handler: optionClosure),
            UIAction(title : "Estimated due date", handler: optionClosure),
            UIAction(title : "Date of last menstrual period", handler: optionClosure),
            UIAction(title : "Date of conception", handler: optionClosure),
            UIAction(title : "Week pregnant", handler: optionClosure),
            UIAction(title : "Day 3 embryo transfer", handler: optionClosure),
            UIAction(title : "Day 5 embryo transfer", handler: optionClosure)
        ])
        
        DueDatePopupButton.showsMenuAsPrimaryAction = true
        DueDatePopupButton.changesSelectionAsPrimaryAction = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
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
