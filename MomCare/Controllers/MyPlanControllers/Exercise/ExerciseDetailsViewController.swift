//
//  ExerciseDetailsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 07/02/25.
//

import UIKit

class ExerciseDetailsViewController: UIViewController {
    private var rootViewController: UIViewController?

    init(rootViewController: UIViewController) {
        super.init(nibName: "ExerciseDetailsViewController", bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        
        self.rootViewController = rootViewController
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // https://rohittamkhane.medium.com/create-a-custom-alert-controller-in-swift-ef5d715839f5
    func show() {
        rootViewController?.present(self, animated: true, completion: nil)
    }

    @IBAction func crossButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
