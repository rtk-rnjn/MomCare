//
//  BabyMomStatsTipViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/03/25.
//

import UIKit

class BabyMomStatsTipViewController: UIViewController {
    var meAndMyBabyViewController: MeAndMyBabyViewController?

    var babyStatsViewController: BabyStatsViewController?
    var babyMomTipViewController: BabyMomTipViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedShowBabyStatsViewController":
            if let babyStatsViewController = segue.destination as? BabyStatsViewController {
                babyStatsViewController.meAndMyBabyViewController = meAndMyBabyViewController
                self.babyStatsViewController = babyStatsViewController
            }

        case "embedShowBabyMomTipViewController":
            if let babyMomTipViewController = segue.destination as? BabyMomTipViewController {
                babyMomTipViewController.meAndMyBabyViewController = meAndMyBabyViewController
                self.babyMomTipViewController = babyMomTipViewController
            }

        default:
            break
        }
    }

    func updateUI() {
        babyStatsViewController?.updateUI()
        babyMomTipViewController?.updateUI()
    }
}
