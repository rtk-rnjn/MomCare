//
//  BabyStatsViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 21/01/25.
//

import UIKit

class BabyStatsViewController: UIViewController {

    @IBOutlet var heightImage: UIImageView!
    @IBOutlet var scaleImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scaleImage.layer.cornerRadius = 14
        scaleImage.layer.masksToBounds = true

        heightImage.layer.cornerRadius = 14
        heightImage.layer.masksToBounds = true
    }

}
