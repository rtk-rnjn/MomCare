//
//  UIButton+Loading.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

#if canImport(UIKit)
import UIKit

#if !os(tvOS) && !os(watchOS)

extension UIButton {
    /// Replaces the button title with a loading spinner.
    ///
    /// This method hides the button's current title, adds a centered
    /// `UIActivityIndicatorView`, and starts its animation.
    ///
    /// ### Usage
    /// ```swift
    /// myButton.startLoadingAnimation()
    /// ```
    func startLoadingAnimation() {
        setTitle("", for: .normal)

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true

        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// Stops the loading animation and restores the original button title.
    ///
    /// - Parameter title: The title to set back on the button.
    ///
    /// ### Usage
    /// ```swift
    /// myButton.stopLoadingAnimation(withRestoreLabel: "Submit")
    /// ```
    func stopLoadingAnimation(withRestoreLabel title: String) {
        setTitle(title, for: .normal)

        // Remove all activity indicators from the button
        for subview in subviews where subview is UIActivityIndicatorView {
            subview.removeFromSuperview()
        }
    }
}

#endif // !os(tvOS) && !os(watchOS)
#endif // canImport(UIKit)
