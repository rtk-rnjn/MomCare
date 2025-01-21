//
//  MeAndMyBabyViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 17/01/25.
//

import UIKit

class MeAndMyBabyViewController: UIViewController {
    @IBOutlet var trimesterLabel: UILabel!
    @IBOutlet var weekDayLabel: UILabel!
    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet var literalHeightLabel: UILabel!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var literalWeightLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!

    func prepareImageView(for imageView: UIImageView) {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
}
