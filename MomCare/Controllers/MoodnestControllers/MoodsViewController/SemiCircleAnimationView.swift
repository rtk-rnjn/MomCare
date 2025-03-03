//
//  SemiCircleAnimationView.swift
//  MomCare
//
//  Created by Ritik Ranjan on 03/03/25.
//

import UIKit

class SemiCircleAnimationView: UIView {
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShape()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShape()
    }
    
    private func setupShape() {
        layer.addSublayer(shapeLayer)
        updatePath(isFullCircle: true) // Start with a full circle
    }
    
    private func updatePath(isFullCircle: Bool) {
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2
        
        if isFullCircle {
            // Full Circle
            path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        } else {
            // Semicircle (upper half)
            path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.midY))
            path.close()
        }
        
        shapeLayer.path = path.cgPath
    }

    func animateToSemiCircle() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = shapeLayer.path
        updatePath(isFullCircle: false)
        animation.toValue = shapeLayer.path
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .default)
        shapeLayer.add(animation, forKey: "pathAnimation")
    }

    func animateToFullCircle() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = shapeLayer.path
        updatePath(isFullCircle: true)
        animation.toValue = shapeLayer.path
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .default)
        shapeLayer.add(animation, forKey: "pathAnimation")
    }
    
    func setCorner(radius: CGFloat) {
        shapeLayer.cornerRadius = radius
        layer.cornerRadius = radius
    }
    
    func setColor(hex: String) {
        shapeLayer.fillColor = UIColor(hex: hex).cgColor
    }
    
    func setColor(color: CGColor) {
        shapeLayer.fillColor = color
    }
    
    func setBorder(color: CGColor, width: CGFloat) {
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = width
    }
}
