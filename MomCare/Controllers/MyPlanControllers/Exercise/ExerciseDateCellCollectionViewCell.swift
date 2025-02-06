//

//  DietDateCellCollectionViewCell.swift

//  MomCare

//

//  Created by Nupur on 19/01/25.

//

import UIKit

class ExerciseDateCellCollectionViewCell: UICollectionViewCell {

    // MARK: Internal

    @IBOutlet var sundayRing: UIView!
    @IBOutlet var mondayRing: UIView!
    @IBOutlet var tuesdayRing: UIView!
    @IBOutlet var wednesdayRing: UIView!
    @IBOutlet var thursdayRing: UIView!
    @IBOutlet var fridayRing: UIView!
    @IBOutlet var saturdayRing: UIView!
    var index = 0

    var ringViews: [UIView] = []

    func prepareViewRings() {
        ringViews = [
            sundayRing, mondayRing, tuesdayRing, wednesdayRing, thursdayRing, fridayRing, saturdayRing
        ]
        for view in ringViews {
            prepareExerciseRing(with: view)
            setupRing()
        }
    }

    func animateRings(to value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = shapeLayer.strokeEnd
        animation.toValue = value
        animation.duration = 3
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shapeLayer.strokeEnd = value
        shapeLayer.add(animation, forKey: "ringAnimation")
    }

    func setupRing() {
        animateRings(to: 0.5)
    }

    // MARK: Private

    private var backgroundLayer: CAShapeLayer!
    private var shapeLayer: CAShapeLayer!

    private func prepareExerciseRing(with view: UIView) {
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let radius: CGFloat = 14
        let lineWidth: CGFloat = 7

        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 3 / 2, clockwise: true)

        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeColor = Converters.convertHexToUIColor(hex: "E7DBDB").cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        view.layer.addSublayer(backgroundLayer)

        shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = Converters.convertHexToUIColor(hex: "B9898A").cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }

}
