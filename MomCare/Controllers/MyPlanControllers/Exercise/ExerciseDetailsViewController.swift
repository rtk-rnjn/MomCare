//
//  ExerciseDetailsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 07/02/25.
//

import UIKit

class ExerciseDetailsViewController: UIViewController {

    // MARK: Lifecycle

    init(rootViewController: UIViewController) {
        super.init(nibName: "ExerciseDetailsViewController", bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve

        self.rootViewController = rootViewController
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    // https://rohittamkhane.medium.com/create-a-custom-alert-controller-in-swift-ef5d715839f5
    func show(_ exercise: Exercise?) {
        rootViewController?.present(self, animated: true, completion: nil)
    }

    @IBAction func crossButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: Private

    private var rootViewController: UIViewController?

}
