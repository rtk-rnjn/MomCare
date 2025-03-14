//
//  TrimesterStatsViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/03/25.
//

import UIKit

class TrimesterStatsViewController: UIViewController {
    var meAndMyBabyViewController: MeAndMyBabyViewController?

    @IBOutlet var trimesterLabel: UILabel!
    @IBOutlet var weekDayLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let trimesterData = meAndMyBabyViewController?.trimesterData else { return }

        trimesterLabel.text = "Trimester \(trimesterData.trimesterNumber)"
        weekDayLabel.text = "Week \(trimesterData.weekNumber), Day \(trimesterData.dayNumber)"
    }
}
