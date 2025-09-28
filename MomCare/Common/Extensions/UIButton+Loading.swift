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
    func startLoadingAnimation() {
        setTitle("", for: .normal)

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true

        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func stopLoadingAnimation(withRestoreLabel title: String) {
        setTitle(title, for: .normal)

        for subview in subviews where subview is UIActivityIndicatorView {
            subview.removeFromSuperview()
        }
    }
}
#endif // !os(tvOS) && !os(watchOS)
#endif // canImport(UIKit)
