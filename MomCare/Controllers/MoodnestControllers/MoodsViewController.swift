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
            
            // Determine which section the slider is in (divided into 4 parts)
            if value < 0.25 {
                updateUI(backgroundColor: UIColor(hex: "#A8B75C"), eyeType: .happy, mouthType: .smile)
            } else if value < 0.50 {
                updateUI(backgroundColor: UIColor(hex: "#97B1E4"), eyeType: .neutral, mouthType: .straight)
            } else if value < 0.75 {
                updateUI(backgroundColor: UIColor(hex: "#D0A956"), eyeType: .meh, mouthType: .meh)
            } else {
                updateUI(backgroundColor: UIColor(hex: "#E68669"), eyeType: .sad, mouthType: .frown)
            }
        }

        func updateUI(backgroundColor: UIColor, eyeType: EyeType, mouthType: MouthType) {
            self.view.backgroundColor = backgroundColor

            let eyeY = emojiView.bounds.height / 2 - 10
            let leftEyePath: UIBezierPath
            let rightEyePath: UIBezierPath

            switch eyeType {
            case .happy:
                leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 20, height: 20))
                rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 20, y: eyeY, width: 20, height: 20))
            case .neutral:
                leftEyePath = UIBezierPath(rect: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 15, height: 15))
                rightEyePath = UIBezierPath(rect: CGRect(x: emojiView.bounds.midX + 25, y: eyeY, width: 15, height: 15))
            case .meh:
                leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 10, height: 10))
                rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 30, y: eyeY, width: 10, height: 10))
            case .sad:
                leftEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX - 40, y: eyeY, width: 8, height: 8))
                rightEyePath = UIBezierPath(ovalIn: CGRect(x: emojiView.bounds.midX + 32, y: eyeY, width: 8, height: 8))
            }

            leftEye.path = leftEyePath.cgPath
            rightEye.path = rightEyePath.cgPath

            let mouthPath = UIBezierPath()
            switch mouthType {
            case .smile:
                mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 25, y: emojiView.bounds.height / 2 + 40))
                mouthPath.addQuadCurve(to: CGPoint(x: emojiView.bounds.midX + 25, y: emojiView.bounds.height / 2 + 40),
                                       controlPoint: CGPoint(x: emojiView.bounds.midX, y: emojiView.bounds.height / 2 + 55))
            case .straight:
                mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: emojiView.bounds.height / 2 + 30))
                mouthPath.addLine(to: CGPoint(x: emojiView.bounds.midX + 20, y: emojiView.bounds.height / 2 + 30))
            case .meh:
                mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 15, y: emojiView.bounds.height / 2 + 35))
                mouthPath.addLine(to: CGPoint(x: emojiView.bounds.midX + 15, y: emojiView.bounds.height / 2 + 35))
            case .frown:
                mouthPath.move(to: CGPoint(x: emojiView.bounds.midX - 20, y: emojiView.bounds.height / 2 + 35))
                mouthPath.addQuadCurve(to: CGPoint(x: emojiView.bounds.midX + 20, y: emojiView.bounds.height / 2 + 35),
                                       controlPoint: CGPoint(x: emojiView.bounds.midX, y: emojiView.bounds.height / 2 + 15))
            }

            mouth.path = mouthPath.cgPath
        }

    }

    // Enums for Eye and Mouth types
    enum EyeType {
        case happy, neutral, meh, sad
    }

    enum MouthType {
        case smile, straight, meh, frown
    }

    // UIColor Extension for Hex Colors
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
