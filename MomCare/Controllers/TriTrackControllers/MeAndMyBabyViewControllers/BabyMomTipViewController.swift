//
//  BabyMomTipViewController.swift
//  MomCare
//
//  Created by Ritik Ranjan on 21/01/25.
//

import UIKit

class BabyMomTipViewController: UIViewController {

    var meAndMyBabyViewController: MeAndMyBabyViewController?

    @IBOutlet var babyStack: UIStackView!
    @IBOutlet var momStack: UIStackView!

    @IBOutlet var babyTipTextView: UITextView!
    @IBOutlet var momTipTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        babyStack.layer.cornerRadius = 16
        babyStack.layer.masksToBounds = true

        momStack.layer.cornerRadius = 16
        momStack.layer.masksToBounds = true

        updateUI()
    }

    @IBAction func BabySeeMoreTapped(_ sender: UIButton) {
        guard let trimesterData = meAndMyBabyViewController?.trimesterData else { return }
        
        performSegue(withIdentifier: "segueShowBabyCardViewController", sender: trimesterData.babyTipText)
    }

    @IBAction func MomSeeMoreTapped(_ sender: UIButton) {
        guard let trimesterData = meAndMyBabyViewController?.trimesterData else { return }
        
        performSegue(withIdentifier: "segueShowMomCardViewController", sender: trimesterData.momTipText)
    }

    @IBAction func unwindToBabyMomTipViewController(_ segue: UIStoryboardSegue) {}

    func updateUI() {
        guard let trimesterData = meAndMyBabyViewController?.trimesterData else { return }

        babyTipTextView.text = trimesterData.babyTipText
        momTipTextView.text = trimesterData.momTipText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowBabyCardViewController" {
            if let destinationViewController = segue.destination as? UINavigationController, let topViewController = destinationViewController.viewControllers.first as? BabyCardViewController {
                topViewController.babyCardText = sender as? String
            }
        }
        if segue.identifier == "segueShowMomCardViewController" {
            if let destinationViewController = segue.destination as? UINavigationController, let topViewController = destinationViewController.viewControllers.first as? MomCardViewController {
                topViewController.momCardText = sender as? String
            }
        }
    }
}
