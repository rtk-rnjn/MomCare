//
//  SymptomsViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 21/01/25.
//

import UIKit

class SymptomsViewController: UIViewController {
    var triTrackViewController: TriTrackViewController?
    
    var symptomsTableViewController: SymptomsTableViewController?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        symptomsTableViewController?.refreshData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = "embedShowSymptomsTabelViewController"
        if segue.identifier == identifier {
            symptomsTableViewController = segue.destination as? SymptomsTableViewController
        }
    }
}
