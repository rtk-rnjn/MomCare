//
//  UIView+Shimmer.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

#if canImport(UIKit)
import UIKit
import ObjectiveC.runtime

extension UIView {

    /// Private associated object key for storing the shimmer `CAGradientLayer`.
    private static var shimmerLayerKey: UInt8 = 0

    /// Private associated object key for storing whether shimmer is currently active.
    private static var shimmerIsShowingKey: UInt8 = 0

    /// The gradient layer used to display the shimmer effect.
    private var shimmerLayer: CAGradientLayer? {
        get { objc_getAssociatedObject(self, &Self.shimmerLayerKey) as? CAGradientLayer }
        set { objc_setAssociatedObject(self, &Self.shimmerLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Indicates whether the shimmer effect is currently active on the view.
    private var isShimmering: Bool {
        get { (objc_getAssociatedObject(self, &Self.shimmerIsShowingKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &Self.shimmerIsShowingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Starts a shimmer effect on the view using a moving gradient.
    ///
    /// The shimmer effect is achieved by:
    /// 1. Creating a `CAGradientLayer` with the specified colors.
    /// 2. Setting the gradient direction from left to right.
    /// 3. Animating the `locations` property of the gradient to create the appearance
    ///    of a moving highlight across the view.
    /// 4. Repeating the animation indefinitely with autoreverse enabled.
    ///
    /// - Parameters:
    ///   - colors: The colors to use in the gradient. Defaults to light gray shades.
    ///   - duration: The duration of one shimmer animation cycle. Default is 0.5 seconds.
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

    /// Stops the shimmer effect if it is currently active.
    ///
    /// - This method:
    ///   1. Removes all animations from the shimmer layer.
    ///   2. Removes the gradient layer from the view's layer hierarchy.
    ///   3. Resets the internal tracking variables.
    func stopShimmer() {
        guard isShimmering else { return }
        isShimmering = false

        shimmerLayer?.removeAllAnimations()
        shimmerLayer?.removeFromSuperlayer()
        shimmerLayer = nil
    }

    /// Applies a default priority for content hugging and compression resistance.
    ///
    /// Useful when you want the view to maintain its intrinsic content size in Auto Layout.
    ///
    /// - Parameter priority: The `UILayoutPriority` to apply. Defaults to `.required`.
    func applyDefaultPriorities(priority: UILayoutPriority = .required) {
        setContentHuggingPriority(priority, for: .horizontal)
        setContentHuggingPriority(priority, for: .vertical)
        setContentCompressionResistancePriority(priority, for: .horizontal)
        setContentCompressionResistancePriority(priority, for: .vertical)
    }
}
#endif // canImport(UIKit)
