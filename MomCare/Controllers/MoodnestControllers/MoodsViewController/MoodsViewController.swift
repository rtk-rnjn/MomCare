//
//  MoodsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

class MoodsViewController: UIViewController {

    @IBOutlet var rightEyeView: SemiCircleAnimationView!
    @IBOutlet var leftEyeView: SemiCircleAnimationView!
    @IBOutlet var smileView: UIView!
    @IBOutlet var slider: UISlider!

    @IBOutlet var moodLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        smileView.backgroundColor = .clear
        rightEyeView.backgroundColor = .clear
        leftEyeView.backgroundColor = .clear

        makeHappyFace()
        makeSmile()
    }

    @IBAction func SetMoodButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueShowMoodNestViewController", sender: nil)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        slider.value = Float(round(sender.value))

        UIView.animate(withDuration: 0.5) {
            self.resetTransformations()
            switch sender.value {
            case 0..<1:
                self.makeHappyFace()
                self.moodLabel.text = "Happy"

            case 1..<2:
                self.makeStressedFace()
                self.moodLabel.text = "Stressed"

            case 2..<3:
                self.makeSadFace()
                self.moodLabel.text = "Sad"

            case 3:
                self.makeAngryFace()
                self.moodLabel.text = "Angry"

            default:
                break
            }
        }
    }
}
