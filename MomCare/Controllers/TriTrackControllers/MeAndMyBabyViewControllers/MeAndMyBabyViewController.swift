//
//  MeAndMyBabyViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class MeAndMyBabyViewController: UIViewController {

    var trimesterData: TrimesterData? {
        let pregnancyData = Utils.pregnancyWeekAndDay(dueDate: MomCareUser.shared.user?.medicalData?.dueDate ?? Date())
        guard let pregnancyData else { return nil }
        guard let data = TriTrackData.getTrimesterData(for: pregnancyData.week) else { return nil }

        return data
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedShowTrimesterStatsViewController":
            let trimesterStatsViewController = segue.destination as? TrimesterStatsViewController
            trimesterStatsViewController?.meAndMyBabyViewController = self

        case "embedShowBabyMomStatsTipViewController":
            let babyMomStatsTipViewController = segue.destination as? BabyMomStatsTipViewController
            babyMomStatsTipViewController?.meAndMyBabyViewController = self

        default:
            break
        }
    }

    func prepareImageView(for imageView: UIImageView) {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
}
