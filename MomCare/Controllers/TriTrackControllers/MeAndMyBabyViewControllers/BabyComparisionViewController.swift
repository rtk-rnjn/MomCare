//
//  BabyComparisionViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 04/03/25.
//

import UIKit

class BabyComparisionViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet weak var babyFetalImage: UIImageView!
    
    func updateUI(withImageView: UIImage,withBabyImage: UIImage, andQuote: String) {
        imageView.image = withImageView
        babyFetalImage.image = withBabyImage
        quoteLabel.text = andQuote
    }

}
