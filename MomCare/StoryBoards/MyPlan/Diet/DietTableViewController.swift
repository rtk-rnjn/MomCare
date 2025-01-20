import UIKit

class DietTableViewController: UITableViewController {
    
    @IBOutlet var DietTableView: UITableView!
    
    let sectionsData: [(firstCellCount: Int, secondCellCount: Int)] = [
        (firstCellCount: 1, secondCellCount: 3), // Section 1: 1 first cell, 3 second cells
        (firstCellCount: 1, secondCellCount: 2), // Section 2: 1 first cell, 2 second cells
        (firstCellCount: 1, secondCellCount: 4), // Section 3: 1 first cell, 4 second cells
        (firstCellCount: 1, secondCellCount: 1)  // Section 4: 1 first cell, 1 second cell
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DietTableView.register(UINib(nibName: "headerCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        DietTableView.register(UINib(nibName: "contentCell", bundle: nil), forCellReuseIdentifier: "contentCell")
        DietTableView.delegate = self
        DietTableView.dataSource = self
        DietTableView.reloadData()
        DietTableView.showsVerticalScrollIndicator = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionsData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionData = sectionsData[section]
        return sectionData.firstCellCount + sectionData.secondCellCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = sectionsData[indexPath.section]
            
            if indexPath.row < sectionData.firstCellCount {
                // Return the first nib cell (present once per section)
                let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderTableViewCell
                // Configure if needed
                return cell
            } else {
                // Return the second nib cell (variable number of times per section)
                let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as! ContentTableViewCell
                // Configure if needed
                return cell
            }
    }
}
