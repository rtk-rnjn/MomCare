import SwiftUI
import UIKit

class SemiCircleAnimationView: UIView {

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShape()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShape()
    }

    // MARK: Internal

    override func layoutSubviews() {
        super.layoutSubviews()

        updatePath(isFullCircle: isFullCircle)
        shapeLayer.frame = bounds
    }

    func animateToSemiCircle() {
        isFullCircle = false
        animatePathChange()
    }

    func animateToFullCircle() {
        isFullCircle = true
        animatePathChange()
    }

    func setCorner(radius: CGFloat) {
        shapeLayer.cornerRadius = radius
        layer.cornerRadius = radius
    }

    func setColor(hex: String) {
        shapeLayer.fillColor = UIColor(Color(hex: hex)).cgColor
    }

    func setColor(color: CGColor) {
        shapeLayer.fillColor = color
    }

    func setBorder(color: CGColor, width: CGFloat) {
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = width
    }

    // MARK: Private

    private let shapeLayer: CAShapeLayer = .init()
    private var isFullCircle: Bool = true

    private func setupShape() {
        layer.addSublayer(shapeLayer)
        shapeLayer.contentsScale = UIScreen.main.scale
        shapeLayer.fillColor = UIColor.black.cgColor
    }

    private func animatePathChange() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = shapeLayer.path

        updatePath(isFullCircle: isFullCircle)

        animation.toValue = shapeLayer.path
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        shapeLayer.add(animation, forKey: "pathAnimation")
    }

    private func updatePath(isFullCircle: Bool) {
        guard bounds.width > 0 else { return }

        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2

        if isFullCircle {
            path.addArc(
                withCenter: center,
                radius: radius,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            )
        } else {
            path.addArc(
                withCenter: center,
                radius: radius,
                startAngle: 0,
                endAngle: .pi,
                clockwise: true
            )
            path.addLine(to: CGPoint(x: bounds.minX, y: bounds.midY))
            path.close()
        }

        shapeLayer.path = path.cgPath
    }
}
