//
//  BabyMomTipViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 21/01/25.
//

import UIKit

class BabyMomTipViewController: UIViewController {

    @IBOutlet var babyStack: UIStackView!
    @IBOutlet var momStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        babyStack.layer.cornerRadius = 14
        babyStack.layer.masksToBounds = true

        momStack.layer.cornerRadius = 14
        momStack.layer.masksToBounds = true
    }

}
