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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueShowMoodNestViewController", let destination = segue.destination as? MoodNestViewController, let mood = sender as? MoodType {

            destination.mood = mood

        }

    }

    @IBAction func setMoodButtonTapped(_ sender: UIButton) {

        let moodHistory = MoodHistory(date: Date(), mood: MoodType(rawValue: moodLabel.text ?? "") ?? .happy)

        MomCareUser.shared.user?.moodHistory.append(moodHistory)

        performSegue(withIdentifier: "segueShowMoodNestViewController", sender: MoodType(rawValue: moodLabel.text ?? ""))

    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {

        slider.value = Float(round(sender.value))

        UIView.animate(withDuration: 0.5) {

            self.resetTransformations()

            switch sender.value {

            case 0..<1:

                self.makeHappyFace()

                self.moodLabel.text = "Happy"

                self.moodLabel.accessibilityLabel = "Mood name: Happy"

            case 1..<2:

                self.makeStressedFace()

                self.moodLabel.text = "Stressed"

                self.moodLabel.accessibilityLabel = "Mood name: Stressed"

            case 2..<3:

                self.makeSadFace()

                self.moodLabel.text = "Sad"

                self.moodLabel.accessibilityLabel = "Mood name: Sad"

            case 3:

                self.makeAngryFace()

                self.moodLabel.text = "Angry"

                self.moodLabel.accessibilityLabel = "Mood name: Angry"

            default:

                break

            }

        }

    }

}
