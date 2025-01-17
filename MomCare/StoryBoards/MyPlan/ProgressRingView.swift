//
//  ProgressRingView.swift
//  MomCare
//
//  Created by Aryan Singh on 17/01/25.
//

import UIKit

class ProgressRingView: UIView {

    private var progressLayer: CAShapeLayer!
        var progress: CGFloat = 0 {
            didSet {
                setProgress(progress)
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupProgressLayer()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupProgressLayer()
        }

        private func setupProgressLayer() {
            let radius = min(bounds.width, bounds.height) / 2
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi - CGFloat.pi / 2, clockwise: true)

            progressLayer = CAShapeLayer()
            progressLayer.path = path.cgPath
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeColor = UIColor.blue.cgColor
            progressLayer.lineWidth = 10
            progressLayer.strokeEnd = 0
            layer.addSublayer(progressLayer)
        }

        private func setProgress(_ progress: CGFloat) {
            progressLayer.strokeEnd = progress
        }

}
