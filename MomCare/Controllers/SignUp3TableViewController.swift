//
//  SignUp3TableViewController.swift
//  MomCare
//
//  Created by Nupur on 14/01/25.
//

import UIKit

class SignUp3TableViewController: UITableViewController {

    
    @IBOutlet weak var DueDatePopupButton: UIButton!
    @IBOutlet weak var ExistingConditionPopupButton: UIButton!
    @IBOutlet weak var FoodIntolerancePopupButton: UIButton!
    @IBOutlet weak var DietaryPreferencePopupButton: UIButton!
    
    @IBOutlet weak var weekPullDownButton: UIButton!
    @IBOutlet weak var dayPullDownButton: UIButton!
    
    var isAdditionalRowVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetDueDatePopUpButton()
        SetExistingConditionPopUpButton()
        SetFoodIntolerancePopUpButton()
        SetDietaryPreferencePopUpButton()
        
        weekPullDownButton.isHidden = true
        dayPullDownButton.isHidden = true
        
        
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

    
    func SetExistingConditionPopUpButton(){
        let optionClosure = {(action: UIAction) in print(action.title)}
        ExistingConditionPopupButton.menu = UIMenu(children : [
            UIAction(title : "None", state :.on , handler: optionClosure),
            UIAction(title : "Diabetes (Type 1, Type 2, Gestational)", handler: optionClosure),
            UIAction(title : "Hypertension", handler: optionClosure),
            UIAction(title : "Polycystic Ovary Syndrome (PCOS)", handler: optionClosure),
            UIAction(title : "Anemia", handler: optionClosure),
            UIAction(title : "Asthma", handler: optionClosure),
            UIAction(title : "Heart Disease", handler: optionClosure),
            UIAction(title : "Kidney Disease", handler: optionClosure)
        ])
        
        ExistingConditionPopupButton.showsMenuAsPrimaryAction = true
        ExistingConditionPopupButton.changesSelectionAsPrimaryAction = true
    }
    
    func SetFoodIntolerancePopUpButton(){
        let optionClosure = {(action: UIAction) in print(action.title)}
        FoodIntolerancePopupButton.menu = UIMenu(children : [
            UIAction(title : "None", state :.on , handler: optionClosure),
            UIAction(title : "Lactose Intolerance", handler: optionClosure),
            UIAction(title : "Gluten Sensitivity", handler: optionClosure),
            UIAction(title : "Egg Allergy", handler: optionClosure),
            UIAction(title : "Seafood Allergy", handler: optionClosure),
            UIAction(title : "Soy Allergy", handler: optionClosure),
            UIAction(title : "Dairy Allergy", handler: optionClosure),
            UIAction(title : "Wheat Allergy", handler: optionClosure),
            UIAction(title : "Others", handler: optionClosure)
        ])
        
        FoodIntolerancePopupButton.showsMenuAsPrimaryAction = true
        FoodIntolerancePopupButton.changesSelectionAsPrimaryAction = true
    }
    
    
    func SetDietaryPreferencePopUpButton(){
        let optionClosure = {(action: UIAction) in print(action.title)}
        DietaryPreferencePopupButton.menu = UIMenu(children : [
            UIAction(title : "None",attributes: [.disabled], state :.on , handler: optionClosure),
            UIAction(title : "Vegetarian", handler: optionClosure),
            UIAction(title : "Non-Vegetarian", handler: optionClosure),
            UIAction(title : "Vegan", handler: optionClosure),
            UIAction(title : "Pescatarian", handler: optionClosure),
            UIAction(title : "Flexitarian", handler: optionClosure),
            UIAction(title : "Gluten-Free", handler: optionClosure),
            UIAction(title : "Low-Carb / Ketogenic", handler: optionClosure),
            UIAction(title : "High-Protein", handler: optionClosure),
            UIAction(title : "Dairy-Free", handler: optionClosure),
            UIAction(title : "Low-Sodium", handler: optionClosure)
        ])
        
        DietaryPreferencePopupButton.showsMenuAsPrimaryAction = true
        DietaryPreferencePopupButton.changesSelectionAsPrimaryAction = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
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
