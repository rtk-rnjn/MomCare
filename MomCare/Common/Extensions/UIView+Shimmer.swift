//
//  UIView+Shimmer.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import UIKit

nonisolated(unsafe) private var shimmerLayerKey: UInt8 = 0
nonisolated(unsafe) private var shimmerIsShowingKey: UInt8 = 0

extension UIView {
    private var shimmerLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &shimmerLayerKey) as? CAGradientLayer
        }
        set {
            objc_setAssociatedObject(self, &shimmerLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var isShimmering: Bool {
        get {
            return (objc_getAssociatedObject(self, &shimmerIsShowingKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &shimmerIsShowingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func startShimmer(
        colors: [UIColor] = [
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0),
            UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        ],
        duration: TimeInterval = 0.5
    ) {
        guard !isShimmering else { return }
        isShimmering = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.name = "shimmerLayer"

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.5, 1]
        animation.toValue = [1, 1.5, 2]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.autoreverses = true

        gradientLayer.add(animation, forKey: "shimmerAnimation")
        layer.addSublayer(gradientLayer)

        shimmerLayer = gradientLayer
    }

    func stopShimmer() {
        guard isShimmering else { return }
        isShimmering = false

        shimmerLayer?.removeAllAnimations()
        shimmerLayer?.removeFromSuperlayer()
        shimmerLayer = nil
    }

    func applyDefaultPriorities(priority: UILayoutPriority = .required) {
        setContentHuggingPriority(priority, for: .horizontal)
        setContentHuggingPriority(priority, for: .vertical)
        setContentCompressionResistancePriority(priority, for: .horizontal)
        setContentCompressionResistancePriority(priority, for: .vertical)
    }

}
