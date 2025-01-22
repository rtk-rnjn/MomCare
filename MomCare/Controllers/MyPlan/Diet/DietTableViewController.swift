import UIKit

class DietTableViewController: UITableViewController {
    
    @IBOutlet var dietTableView: UITableView!
    
    let sectionsData: [(firstCellCount: Int, secondCellCount: Int)] = [
        (firstCellCount: 1, secondCellCount: 3), // Section 1: 1 first cell, 3 second cells
        (firstCellCount: 1, secondCellCount: 2), // Section 2: 1 first cell, 2 second cells
        (firstCellCount: 1, secondCellCount: 4), // Section 3: 1 first cell, 4 second cells
        (firstCellCount: 1, secondCellCount: 1)  // Section 4: 1 first cell, 1 second cell
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dietTableView.register(UINib(nibName: "HeaderCell", bundle: nil), forCellReuseIdentifier: "HeaderCell")
        dietTableView.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
        dietTableView.delegate = self
        dietTableView.dataSource = self
        dietTableView.reloadData()
        dietTableView.showsVerticalScrollIndicator = false
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderTableViewCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as! ContentTableViewCell
        }
    }
}
