//
//  UIKit+AccessibilityHelpers.swift
//  MomCare
//
//  Created by Copilot on 14/09/2024.
//

import UIKit

/// Protocol for ViewControllers that want to implement accessibility
protocol AccessibilityConfigurable {
    func setupAccessibility()
    func updateAccessibilityForContentChanges()
}

class UIKitAccessibilityHelper {
    
    static func configureTableViewCellWithSelectableTraits(
        _ cell: UITableViewCell,
        title: String,
        subtitle: String? = nil,
        accessoryDescription: String? = nil,
        isSelectable: Bool = true
    ) {
        var accessibilityText = title
        
        if let subtitle = subtitle {
            accessibilityText += ", \(subtitle)"
        }
        
        if let accessoryDescription = accessoryDescription {
            accessibilityText += ", \(accessoryDescription)"
        }
        
        cell.accessibilityLabel = accessibilityText
        cell.accessibilityTraits = isSelectable ? [.button] : [.staticText]
        
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.adjustsFontForContentSizeCategory = true
    }
    
    static func configureCollectionViewCellWithPositionInfo(
        _ cell: UICollectionViewCell,
        title: String,
        description: String? = nil,
        position: String? = nil
    ) {
        var accessibilityText = title
        
        if let description = description {
            accessibilityText += ", \(description)"
        }
        
        if let position = position {
            accessibilityText += ", \(position)"
        }
        
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = accessibilityText
        cell.accessibilityTraits = [.button]
    }
    
    static func configureNavigationControllerWithButtonTraits(_ navigationController: UINavigationController) {
        navigationController.navigationBar.accessibilityElementsHidden = false
        
        navigationController.navigationBar.subviews.forEach { view in
            if let button = view as? UIButton {
                button.accessibilityTraits = [.button]
            }
        }
    }
    
    static func configureTabBarControllerWithPositionalHints(_ tabBarController: UITabBarController) {
        tabBarController.tabBar.accessibilityElementsHidden = false
        
        tabBarController.tabBar.items?.enumerated().forEach { index, item in
            item.accessibilityLabel = item.title
            item.accessibilityTraits = [.button]
            item.accessibilityHint = "Tab \(index + 1) of \(tabBarController.tabBar.items?.count ?? 1)"
        }
    }
    
    static func configureAlertControllerWithActionHints(_ alertController: UIAlertController) {
        if let title = alertController.title {
            alertController.setValue(title, forKey: "accessibilityLabel")
        }
        
        if let message = alertController.message {
            alertController.setValue(message, forKey: "accessibilityValue")
        }
        
        alertController.actions.forEach { action in
            action.accessibilityTraits = [.button]
            if action.style == .cancel {
                action.accessibilityHint = "Cancel and dismiss alert"
            } else if action.style == .destructive {
                action.accessibilityHint = "Destructive action"
                action.accessibilityTraits.insert(.keyboardKey)
            }
        }
    }
    
    static func configureTextViewWithDynamicType(_ textView: UITextView, placeholder: String? = nil) {
        textView.accessibilityTraits = [.keyboardKey]
        textView.adjustsFontForContentSizeCategory = true
        
        if let placeholder = placeholder {
            textView.accessibilityHint = placeholder
        }
    }
    
    static func configureScrollViewWithContentDescription(_ scrollView: UIScrollView, contentDescription: String? = nil) {
        scrollView.accessibilityTraits = [.none]
        
        if let description = contentDescription {
            scrollView.accessibilityLabel = description
        }
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
    }
    
    static func configurePageControlWithSwipeHints(_ pageControl: UIPageControl, description: String = "Page indicator") {
        pageControl.accessibilityLabel = description
        pageControl.accessibilityTraits = [.adjustable]
        pageControl.accessibilityHint = "Swipe left or right to change pages"
    }
    
    static func configureImageViewWithDecorativeOption(_ imageView: UIImageView, description: String?, isDecorative: Bool = false) {
        if isDecorative {
            imageView.isAccessibilityElement = false
            imageView.accessibilityElementsHidden = true
        } else {
            imageView.isAccessibilityElement = true
            imageView.accessibilityLabel = description
            imageView.accessibilityTraits = [.image]
        }
    }
    
    static func configureActivityIndicatorWithLoadingMessage(_ activityIndicator: UIActivityIndicatorView, loadingMessage: String = "Loading") {
        activityIndicator.accessibilityLabel = loadingMessage
        activityIndicator.accessibilityTraits = [.notEnabled]
    }
    
    static func configureProgressViewWithPercentageValue(_ progressView: UIProgressView, description: String, currentValue: Float? = nil) {
        progressView.accessibilityLabel = description
        progressView.accessibilityTraits = [.updatesFrequently]
        
        if let value = currentValue {
            let percentage = Int(value * 100)
            progressView.accessibilityValue = "\(percentage) percent complete"
        }
    }
    
    static func configureStepperWithValueAndUnit(_ stepper: UIStepper, label: String, unit: String = "") {
        stepper.accessibilityLabel = label
        stepper.accessibilityTraits = [.adjustable]
        
        let currentValue = stepper.value
        stepper.accessibilityValue = "\(currentValue) \(unit)".trimmingCharacters(in: .whitespaces)
        stepper.accessibilityHint = "Swipe up to increase, swipe down to decrease"
    }
    
    static func configureSliderWithRangeInfo(_ slider: UISlider, label: String, unit: String = "", range: String? = nil) {
        slider.accessibilityLabel = label
        slider.accessibilityTraits = [.adjustable]
        
        let currentValue = slider.value
        slider.accessibilityValue = "\(currentValue) \(unit)".trimmingCharacters(in: .whitespaces)
        
        if let range = range {
            slider.accessibilityHint = "Adjustable slider, range \(range)"
        } else {
            slider.accessibilityHint = "Adjustable slider"
        }
    }
}

extension UIFont {
    
    static func accessibleFontWithOptionalMaxSize(size: CGFloat, weight: UIFont.Weight = .regular, maxSize: CGFloat? = nil) -> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        
        if let maxSize = maxSize {
            return UIFontMetrics.default.scaledFont(for: font, maximumPointSize: maxSize)
        } else {
            return UIFontMetrics.default.scaledFont(for: font)
        }
    }
    
    static func accessibleCustomFontWithFallback(name: String, size: CGFloat, maxSize: CGFloat? = nil) -> UIFont? {
        guard let customFont = UIFont(name: name, size: size) else {
            return accessibleFontWithOptionalMaxSize(size: size, maxSize: maxSize)
        }
        
        if let maxSize = maxSize {
            return UIFontMetrics.default.scaledFont(for: customFont, maximumPointSize: maxSize)
        } else {
            return UIFontMetrics.default.scaledFont(for: customFont)
        }
    }
}

extension UIColor {
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    func hasAccessibleContrastWithWCAGValidation(with otherColor: UIColor, isLargeText: Bool = false) -> Bool {
        return AccessibilityUtils.meetsWCAGAA(foreground: self, background: otherColor, isLargeText: isLargeText)
    }
}