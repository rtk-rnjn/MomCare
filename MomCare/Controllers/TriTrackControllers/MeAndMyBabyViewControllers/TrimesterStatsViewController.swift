//
//  TrimesterStatsViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/03/25.
//

import UIKit

class TrimesterStatsViewController: UIViewController {
    var meAndMyBabyViewController: MeAndMyBabyViewController?

    var babyComparisionViewController: BabyComparisionViewController?

    @IBOutlet var trimesterLabel: UILabel!
    @IBOutlet var weekDayLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedShowBabyComparisionViewController", let destination = segue.destination as? BabyComparisionViewController {
            babyComparisionViewController = destination
        }
    }

    func updateUI() {
        guard let trimesterData = meAndMyBabyViewController?.trimesterData else { return }

        trimesterLabel.text = "Trimester \(trimesterData.trimesterNumber)"
        weekDayLabel.text = "Week \(trimesterData.weekNumber), Day \(trimesterData.dayNumber ?? 1)"

        Task {
            guard let image = await trimesterData.image else { return }
            self.babyComparisionViewController?.updateUI(withImageView: image, andQuote: trimesterData.quote ?? "")
        }
    }

}
