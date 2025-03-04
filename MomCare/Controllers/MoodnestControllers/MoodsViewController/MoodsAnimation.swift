//
//  MoodsAnimation.swift
//  MomCare
//
//  Created by Ritik Ranjan on 03/03/25.
//

import UIKit

extension MoodsViewController {
    func makeSmile() {
        let width: CGFloat = smileView.frame.width
        let height: CGFloat = smileView.frame.height

        let smilePath = UIBezierPath()
        let startX: CGFloat = 0
        let endX: CGFloat = width
        let controlX: CGFloat = width / 2
        let controlY: CGFloat = height * 2

        smilePath.move(to: CGPoint(x: startX, y: height / 2))
        smilePath.addQuadCurve(to: CGPoint(x: endX, y: height / 2), controlPoint: CGPoint(x: controlX, y: controlY))

        let smileLayer = CAShapeLayer()
        smileLayer.path = smilePath.cgPath
        smileLayer.fillColor = UIColor.clear.cgColor
        smileLayer.strokeColor = UIColor(hex: "5c4131").cgColor
        smileLayer.lineWidth = 20
        smileLayer.lineCap = .round

        smileView.layer.addSublayer(smileLayer)
    }

    func resetTransformations() {
        leftEyeView.transform = .identity
        rightEyeView.transform = .identity

        smileView.transform = .identity

        leftEyeView.animateToFullCircle()
        rightEyeView.animateToFullCircle()
    }

    func makeHappyFace() {
        leftEyeView.layer.cornerRadius = leftEyeView.frame.width / 2
        rightEyeView.layer.cornerRadius = rightEyeView.frame.width / 2

        view.backgroundColor = UIColor(hex: "#ffd0cb")

        leftEyeView.setColor(hex: "#5c4131")
        rightEyeView.setColor(hex: "#5c4131")
        setSmileColor(hex: "#5c4131")

        leftEyeView.transform = CGAffineTransform(scaleX: 1, y: 1)
        rightEyeView.transform = CGAffineTransform(scaleX: 1, y: 1)

        makeSmile()
    }

    func makeSadFace() {
        leftEyeView.layer.cornerRadius = leftEyeView.frame.width / 2
        rightEyeView.layer.cornerRadius = rightEyeView.frame.width / 2

        view.backgroundColor = UIColor(hex: "#8DC1D4")

        leftEyeView.setColor(hex: "#2F4C5A")
        rightEyeView.setColor(hex: "#2F4C5A")
        setSmileColor(hex: "#2F4C5A")

        let scaleTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        leftEyeView.transform = scaleTransform
        rightEyeView.transform = scaleTransform

        let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi)
        smileView.transform = rotateTransform
    }

    func makeStressedFace() {
        let scaleTransform = CGAffineTransform(scaleX: 0.8, y: 0.2)

        view.backgroundColor = UIColor(hex: "#D5E5C9")

        leftEyeView.setColor(hex: "#4A593D")
        rightEyeView.setColor(hex: "#4A593D")
        setSmileColor(hex: "#4A593D")

        leftEyeView.transform = scaleTransform
        rightEyeView.transform = scaleTransform

        let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi)
        smileView.transform = rotateTransform
    }

    func makeAngryFace() {
        let scaleTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        view.backgroundColor = UIColor(hex: "#F79E90")
        leftEyeView.setColor(hex: "583933")
        rightEyeView.setColor(hex: "583933")
        setSmileColor(hex: "583933")

        let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi)

        let leftTilt = CGAffineTransform(rotationAngle: CGFloat.pi / 6)
        let rightTilt = CGAffineTransform(rotationAngle: -CGFloat.pi / 6)

        smileView.transform = rotateTransform
        leftEyeView.animateToSemiCircle()
        rightEyeView.animateToSemiCircle()

        leftEyeView.transform = scaleTransform.concatenating(leftTilt)
        rightEyeView.transform = scaleTransform.concatenating(rightTilt)
    }

    func setSmileColor(hex: String) {
        for layer in smileView.layer.sublayers ?? [] {
            if let layer = layer as? CAShapeLayer {
                layer.strokeColor = UIColor(hex: hex).cgColor
            }
        }
    }
}
