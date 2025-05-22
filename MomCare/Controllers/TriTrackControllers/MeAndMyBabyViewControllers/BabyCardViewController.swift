//
//  BabyCardViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 05/03/25.
//

import UIKit

class BabyCardViewController: UIViewController {

    @IBOutlet var babyCardTextView: UITextView!
    var babyCardText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "ECC7BA")
        babyCardTextView.backgroundColor = UIColor(hex: "ECC7BA")

        babyCardTextView.text = babyCardText
    }

    @IBAction func babyCardButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
