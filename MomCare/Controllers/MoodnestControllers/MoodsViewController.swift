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
    
    @IBOutlet weak var emojiView: UIView!
    @IBOutlet weak var moodSlider: UISlider!
    
    private let leftEye = CAShapeLayer()
    private let rightEye = CAShapeLayer()
    private let mouth = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmojiFace()
        moodSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    
    
    func setupEmojiFace() {
        emojiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let eyeRadius: CGFloat = 20
        let eyeSpacing: CGFloat = 40
        let centerY = emojiView.bounds.height / 2
        
        // Initial eye positions
        let leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - eyeSpacing, y: centerY - eyeRadius, width: eyeRadius, height: eyeRadius))
        let rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + eyeSpacing - eyeRadius, y: centerY - eyeRadius, width: eyeRadius, height: eyeRadius))
        
        leftEye.path = leftEyePath.cgPath
        rightEye.path = rightEyePath.cgPath
        leftEye.fillColor = UIColor.black.cgColor
        rightEye.fillColor = UIColor.black.cgColor
        
        // Initial mouth (neutral straight line)
        let mouthPath = UIBezierPath()
        mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: centerY + 20))
        mouthPath.addLine(to: CGPoint(x: emojiView.bounds.midX + 20, y: centerY + 20))
        
        mouth.path = mouthPath.cgPath
        mouth.strokeColor = UIColor.black.cgColor
        mouth.lineWidth = 4
        mouth.lineCap = .round
        
        emojiView.layer.addSublayer(leftEye)
        emojiView.layer.addSublayer(rightEye)
        emojiView.layer.addSublayer(mouth)
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        let value = sender.value

        // Adjust the main view's background color based on slider value
        if value < 0.33 {
            self.view.backgroundColor = UIColor(hex: "#E68669") // Sad 😢
        } else if value < 0.66 {
            self.view.backgroundColor = UIColor(hex: "#D0A956") // Neutral 😐
        } else {
            self.view.backgroundColor = UIColor(hex: "#A8B75C") // Happy 😀
        }

        // Adjust eye shapes
        let eyeSize = CGFloat(20 + (value * 15)) // Smallest at min, largest at max
        let eyeY = emojiView.bounds.height / 2 - eyeSize / 2

        let leftEyePath: UIBezierPath
        let rightEyePath: UIBezierPath

        if value < 0.33 {
            // Sad (Small Eyes, Upside-Down Smile)
            leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 10, height: 10))
            rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: 10, height: 10))

            let mouthPath = UIBezierPath()
            mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: emojiView.bounds.height / 2 + 35))
            mouthPath.addQuadCurve(to: CGPoint(x: emojiView.bounds.midX + 20, y: emojiView.bounds.height / 2 + 35),
                                   controlPoint: CGPoint(x: emojiView.bounds.midX, y: emojiView.bounds.height / 2 + 10))

            mouth.path = mouthPath.cgPath
            mouth.strokeColor = UIColor.black.cgColor
            mouth.lineWidth = 4
            mouth.fillColor = UIColor.clear.cgColor // Line-only smile

        } else if value < 0.66 {
            // Meh (Rectangle Eyes, Straight Line Mouth)
            leftEyePath = UIBezierPath(rect: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 15, height: 20))
            rightEyePath = UIBezierPath(rect: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: 15, height: 20))

            let mouthPath = UIBezierPath()
            mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: emojiView.bounds.height / 2 + 30))
            mouthPath.addLine(to: CGPoint(x: emojiView.bounds.midX + 20, y: emojiView.bounds.height / 2 + 30))
            mouth.path = mouthPath.cgPath

        } else {
            // Happy (Big Round Eyes, Smiley Mouth)
            leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: eyeSize, height: eyeSize))
            rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: eyeSize, height: eyeSize))

            let mouthPath = UIBezierPath()
            mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 25, y: emojiView.bounds.height / 2 + 40))
            mouthPath.addQuadCurve(to: CGPoint(x: emojiView.bounds.midX + 25, y: emojiView.bounds.height / 2 + 40),
                                   controlPoint: CGPoint(x: emojiView.bounds.midX, y: emojiView.bounds.height / 2 + 55))

            mouth.path = mouthPath.cgPath
            mouth.strokeColor = UIColor.black.cgColor
            mouth.lineWidth = 5
            mouth.fillColor = UIColor.clear.cgColor // No fill, only stroke
        }

        leftEye.path = leftEyePath.cgPath
        rightEye.path = rightEyePath.cgPath
    }

}


extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
