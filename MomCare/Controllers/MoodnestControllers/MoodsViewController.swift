//
//  MoodsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

class MoodsViewController: UIViewController {

    @IBOutlet var happySliderPoint: UIView!
    @IBOutlet var sadSliderPoint: UIView!
    @IBOutlet var stressedSliderPoint: UIView!
    @IBOutlet var angrySliderPoint: UIView!

    @IBOutlet var emojiView: UIImageView!
    @IBOutlet var moodSlider: UISlider!
    @IBOutlet var moodLabel: UILabel!

    let moodImages = [
        UIImage(named: "Happy"),
        UIImage(named: "Stressed"),
        UIImage(named: "Sad"),
        UIImage(named: "Angry")
    ]
    let moodTexts = ["Happy", "Stressed", "Sad", "Angry"]

    let moodHexColors: [String] = [
        // #97B1E4 <blue/indigo?  #D0A956 <yellow>  #A8B75C <green>   #E68669 <Red>
            "#D0A956",
            "#A8B75C",
            "#97B1E4",
            "#E68669"
            ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlider()
        addTapGestureToSlider()
        updateMoodDisplay(for: Int(moodSlider.value))
        moodSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }

    func setupSlider() {
        moodSlider.minimumValue = 0
        moodSlider.maximumValue = 3
        moodSlider.value = 0
        moodSlider.isContinuous = false
    }

    func updateMoodDisplay(for index: Int) {
        guard index >= 0 && index < moodImages.count else {
            return
        }
        emojiView.image = moodImages[index]
        moodLabel.text = moodTexts[index]

        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = self.hexStringToUIColor(self.moodHexColors[index])
        }
        UIView.transition(with: emojiView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.emojiView.image = self.moodImages[index]
        }, completion: nil)
    }

    func addTapGestureToSlider() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        moodSlider.addGestureRecognizer(tapGesture)
    }

    @objc func sliderChanged(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.setValue(roundedValue, animated: true)
        updateMoodDisplay(for: Int(roundedValue))
    }

    @objc func sliderTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: moodSlider)
        let sliderWidth = moodSlider.bounds.width
        let stepWidth = sliderWidth / 4 // Divide by 4 instead of 3 to cover all 4 steps

        var index = Int(location.x / stepWidth + 0.5) // +0.5 for better rounding behavior
        index = min(max(index, 0), 3) // Ensure index stays between 0 and 3

        moodSlider.setValue(Float(index), animated: true)
        updateMoodDisplay(for: index)
    }

    func hexStringToUIColor(_ hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.removeFirst()
        }

        if cString.count != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgbValue >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgbValue & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    
    @IBAction func SetMoodButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueShowMoodNestViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowMoodNestViewController",
           let destination = segue.destination as? MoodNestViewController {
            destination.iconImageView = emojiView.image
        }
    }
}
