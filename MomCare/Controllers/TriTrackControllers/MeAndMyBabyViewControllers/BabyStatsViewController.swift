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

        guard let trimesterData = meAndMyBabyViewController?.trimesterData else { return }

        heightLabel.text = "\(trimesterData.babyHeightInCentimeters) cm"
        weightLabel.text = "\(trimesterData.babyWeightInKilograms * 1000) g"

    }

}
