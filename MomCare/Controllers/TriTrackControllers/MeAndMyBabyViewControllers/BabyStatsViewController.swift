//
//  BabyStatsViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 21/01/25.
//

import UIKit

class BabyStatsViewController: UIViewController {

    var meAndMyBabyViewController: MeAndMyBabyViewController?

    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!

    @IBOutlet var heightImage: UIImageView!
    @IBOutlet var scaleImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scaleImage.layer.cornerRadius = 14
        scaleImage.layer.masksToBounds = true

        heightImage.layer.cornerRadius = 14
        heightImage.layer.masksToBounds = true

        updateUI()
    }

    func updateUI() {
        let trimesterData = meAndMyBabyViewController?.trimesterData

        let height: Double? = trimesterData?.babyHeightInCentimeters
        let weight: Double? = trimesterData?.babyWeightInGrams

        if height != nil {
            heightLabel.text = "\(height!) cm"
        } else {
            heightLabel.text = "N/A"
        }

        if weight != nil {
            weightLabel.text = "\(weight!) g"
        } else {
            weightLabel.text = "N/A"
        }
    }

}
