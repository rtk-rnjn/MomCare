//
//  BabyMomStatsTipViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/03/25.
//

import UIKit

class BabyMomStatsTipViewController: UIViewController {
    var meAndMyBabyViewController: MeAndMyBabyViewController?

    @IBOutlet var BabyMomStatsTipLoweView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedShowBabyStatsViewController":
            let babyStatsViewController = segue.destination as? BabyStatsViewController
            babyStatsViewController?.meAndMyBabyViewController = meAndMyBabyViewController

        case "embedShowBabyMomTipViewController":
            let babyMomTipViewController = segue.destination as? BabyMomTipViewController
            babyMomTipViewController?.meAndMyBabyViewController = meAndMyBabyViewController

        default:
            break
        }
    }
}
