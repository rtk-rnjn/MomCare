//
//  BabyCardViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 05/03/25.
//

import UIKit

class BabyCardViewController: UIViewController {

    @IBOutlet var babyCardTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "ECC7BA")
        babyCardTextView.backgroundColor = UIColor(hex: "ECC7BA")
    }

    @IBAction func babyCardButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
