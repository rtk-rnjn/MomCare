//
//  CircularProgressView.swift
//  MomCare
//
//  Created by Batch - 2  on 20/01/25.
//

import UIKit

class CircularProgressView: UIView {

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    // MARK: Internal

    var progress: CGFloat = 0.0 {
        didSet {
            updateProgress()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        setupLayer()
    }

    // MARK: Private

    private let progressLayer: CAShapeLayer = .init()

    private func setupLayer() {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.width, bounds.height) / 2 - 5, // Adjust radius
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 5
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    private func updateProgress() {
        progressLayer.strokeEnd = progress
    }
}
