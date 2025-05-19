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

    func updateUI(withImageView: UIImage, andQuote: String) {
        imageView.image = withImageView
        quoteLabel.text = andQuote
    }

}
