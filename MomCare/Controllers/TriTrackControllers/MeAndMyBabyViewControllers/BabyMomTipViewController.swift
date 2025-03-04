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
        
        guard let trimesterData = meAndMyBabyViewController?.trimesterData else { return }
        
        babyTipTextView.text = trimesterData.babyTipText
        momTipTextView.text = trimesterData.momTipText
    }
    
    @IBAction func BabySeeMoreTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "MeAndMyBaby", bundle: nil)
        if let fullScreenVC = storyboard.instantiateViewController(withIdentifier: "FullScreenBabyCardViewController") as? BabyCardViewController {
            fullScreenVC.modalPresentationStyle = .fullScreen
            present(fullScreenVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func MomSeeMoreTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "MeAndMyBaby", bundle: nil)
        if let fullScreenVC = storyboard.instantiateViewController(withIdentifier: "FullScreenMomCardViewController") as? MomCardViewController {
            fullScreenVC.modalPresentationStyle = .fullScreen
            present(fullScreenVC, animated: true, completion: nil)
        }
    }

}

