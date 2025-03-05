//
//  BabyAndMomCardViewController.swift
//  MomCare
//
//  Created by Khushi Rana on 04/03/25.
//

import UIKit

class MomCardViewController: UIViewController {
    
    @IBOutlet var momCardTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "ECC7BA")
        momCardTextView.backgroundColor = UIColor(hex: "ECC7BA")

    }
    
    
    @IBAction func MomCardCancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
