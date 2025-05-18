//
//  MeAndMyBabyViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class MeAndMyBabyViewController: UIViewController {
    var triTrackViewController: TriTrackViewController?

    @IBOutlet var MeAndMyBabyUpperView: UIView!
    @IBOutlet var MeAndMyBabyLowerView: UIView!

    var trimesterStatsViewController: TrimesterStatsViewController?
    var babyMomStatsTipViewController: BabyMomStatsTipViewController?

    var trimesterData: TrimesterData? {
        let dueDate = MomCareUser.shared.user?.medicalData?.dueDate ?? triTrackViewController?.selectedFSCalendarDate ?? Date()
        let pregnancyData = Utils.pregnancyWeekAndDay(dueDate: dueDate)
        guard let pregnancyData else { return nil }
        guard var data = TriTrackData.getTrimesterData(for: pregnancyData.week) else { return nil }
        data.dayNumber = pregnancyData.day
        return data
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedShowTrimesterStatsViewController":
            if let trimesterStatsViewController = segue.destination as? TrimesterStatsViewController {
                trimesterStatsViewController.meAndMyBabyViewController = self
                self.trimesterStatsViewController = trimesterStatsViewController
            }

        case "embedShowBabyMomStatsTipViewController":
            if let babyMomStatsTipViewController = segue.destination as? BabyMomStatsTipViewController {
                babyMomStatsTipViewController.meAndMyBabyViewController = self
                self.babyMomStatsTipViewController = babyMomStatsTipViewController
            }

        default:
            break
        }
    }

    func prepareImageView(for imageView: UIImageView) {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }

    func refreshData() {
        trimesterStatsViewController?.updateUI()
        babyMomStatsTipViewController?.updateUI()
    }
}
