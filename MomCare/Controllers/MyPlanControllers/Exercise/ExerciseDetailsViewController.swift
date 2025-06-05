//
//  ExerciseDetailsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 07/02/25.
//

import UIKit

class ExerciseDetailsViewController: UIViewController {

    // MARK: Lifecycle

    init(rootViewController: UIViewController, exercise: Exercise) {
        super.init(nibName: "ExerciseDetailsViewController", bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve

        self.exercise = exercise
        self.rootViewController = rootViewController
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    @IBOutlet var exerciseNameLabel: UILabel!
    @IBOutlet var exerciseDescriptionLabel: UITextView!
    @IBOutlet var exerciseLevelLabelButton: UIButton!

    @IBOutlet var tagsStack: UIStackView!

    var exercise: Exercise?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateElements(with: exercise)
    }

    // https://rohittamkhane.medium.com/create-a-custom-alert-controller-in-swift-ef5d715839f5
    func show() {
        rootViewController?.present(self, animated: true)
    }

    @IBAction func crossButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: Private

    private var rootViewController: UIViewController?

    private func updateElements(with exercise: Exercise?) {
        guard let exercise else { return }

        exerciseNameLabel.text = exercise.name
        exerciseDescriptionLabel.text = exercise.description
        exerciseLevelLabelButton.setTitle(exercise.level.rawValue, for: .normal)

        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for index in exercise.tags.indices {
            let tag = exercise.tags[index]

            let button = UIButton(configuration: .filled(), primaryAction: nil)

            button.configuration?.buttonSize = .medium
            button.configuration?.baseBackgroundColor = .lightGray
            button.configuration?.baseForegroundColor = .black
            button.tintColor = .lightGray
            button.alpha = 0.55

            button.setTitle(tag, for: .normal)

            tagsStack.addArrangedSubview(button)
            if index > 3 {
                break
            }
        }
    }

}
