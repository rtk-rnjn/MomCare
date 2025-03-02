//
//  MoodsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit

class MoodsViewController: UIViewController {
    
    @IBOutlet weak var happySliderPoint: UIView!
    @IBOutlet weak var sadSliderPoint: UIView!
    @IBOutlet weak var stressedSliderPoint: UIView!
    @IBOutlet weak var angrySliderPoint: UIView!
    
    @IBOutlet weak var emojiView: UIImageView!
    @IBOutlet weak var moodSlider: UISlider!
    @IBOutlet weak var moodLabel: UILabel!
    
    let moodImages = [
        UIImage(named: "Happy"),
        UIImage(named: "Stressed"),
        UIImage(named: "Sad"),
        UIImage(named: "Angry")
    ]
    let moodTexts = ["Happy", "Stressed", "Sad", "Angry"]
    
    let moodHexColors: [String] = [
        //#97B1E4 <blue/indigo?  #D0A956 <yellow>  #A8B75C <green>   #E68669 <Red>
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
        moodLabel.alpha = 0.7
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
        let stepWidth = sliderWidth / 3
        
        var index = Int(round(location.x / stepWidth))
        index = min(max(index, 0), 3)

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
}
