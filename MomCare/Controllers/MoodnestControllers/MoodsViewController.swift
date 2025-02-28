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
        setupSlider()
        moodSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    func setupSlider() {
        moodSlider.minimumValue = 0
        moodSlider.maximumValue = 1
        moodSlider.value = 0
        moodSlider.isContinuous = false
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
        // Snap slider to 4 fixed values
        let steps: [Float] = [0.0, 0.33, 0.66, 1.0]
        let closest = steps.min(by: { abs($0 - sender.value) < abs($1 - sender.value) }) ?? 0.0
        sender.setValue(closest, animated: true)
        
        updateUI(for: closest)
    }
    
    func updateUI(for value: Float) {
        switch value {
        case 0.0:
            self.view.backgroundColor = UIColor(hex: "#A8B75C") // Happy 😀
        case 0.33:
            self.view.backgroundColor = UIColor(hex: "#97B1E4") // Calm 😊
        case 0.66:
            self.view.backgroundColor = UIColor(hex: "#D0A956") // Neutral 😐
        case 1.0:
            self.view.backgroundColor = UIColor(hex: "#E68669") // Sad 😢
        default:
            break
        }
        
        updateEmojiFace(for: value)
    }
    
    func updateEmojiFace(for value: Float) {
        let eyeSize = CGFloat(20 + (value * 15))
        let eyeY = emojiView.bounds.height / 2 - eyeSize / 2
        
        let leftEyePath: UIBezierPath
        let rightEyePath: UIBezierPath
        let mouthPath = UIBezierPath()
        
        switch value {
        case 0.0:
            // Happy
            leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: eyeSize, height: eyeSize))
            rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: eyeSize, height: eyeSize))
            mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 25, y: emojiView.bounds.height / 2 + 40))
            mouthPath.addQuadCurve(to: CGPoint(x: emojiView.bounds.midX + 25, y: emojiView.bounds.height / 2 + 40),controlPoint: CGPoint(x: emojiView.bounds.midX, y: emojiView.bounds.height / 2 + 55))
        case 0.33:
            // Calm
            leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 15, height: 15))
            rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: 15, height: 15))
            mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: emojiView.bounds.height / 2 + 30))
            mouthPath.addLine(to: CGPoint(x: emojiView.bounds.midX + 20, y: emojiView.bounds.height / 2 + 30))
        case 0.66:
            // Neutral
            leftEyePath = UIBezierPath(rect: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 15, height: 20))
            rightEyePath = UIBezierPath(rect: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: 15, height: 20))
            mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: emojiView.bounds.height / 2 + 30))
            mouthPath.addLine(to: CGPoint(x: emojiView.bounds.midX + 20, y: emojiView.bounds.height / 2 + 30))
        case 1.0:
            // Sad
            leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 10, height: 10))
            rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: 10, height: 10))
            mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: emojiView.bounds.height / 2 + 35))
            mouthPath.addQuadCurve(to: CGPoint(x: emojiView.bounds.midX + 20, y: emojiView.bounds.height / 2 + 35),controlPoint: CGPoint(x: emojiView.bounds.midX, y: emojiView.bounds.height / 2 + 10))
        default:
            return
        }
        
        leftEye.path = leftEyePath.cgPath
        rightEye.path = rightEyePath.cgPath
        mouth.path = mouthPath.cgPath
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
