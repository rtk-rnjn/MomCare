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

/// Helper class for common UIKit accessibility configurations
class UIKitAccessibilityHelper {
    
    /// Sets up accessibility for table view cells
    static func configureTableViewCell(
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
        
        // Enable Dynamic Type for cell labels
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.detailTextLabel?.adjustsFontForContentSizeCategory = true
    }
    
    /// Sets up accessibility for collection view cells
    static func configureCollectionViewCell(
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
    
    /// Sets up accessibility for navigation controllers
    static func configureNavigationController(_ navigationController: UINavigationController) {
        navigationController.navigationBar.accessibilityElementsHidden = false
        
        // Configure navigation bar buttons
        navigationController.navigationBar.subviews.forEach { view in
            if let button = view as? UIButton {
                button.accessibilityTraits = [.button]
            }
        }
    }
    
    /// Sets up accessibility for tab bar controllers
    static func configureTabBarController(_ tabBarController: UITabBarController) {
        tabBarController.tabBar.accessibilityElementsHidden = false
        
        // Configure tab bar items
        tabBarController.tabBar.items?.enumerated().forEach { index, item in
            item.accessibilityLabel = item.title
            item.accessibilityTraits = [.button]
            item.accessibilityHint = "Tab \(index + 1) of \(tabBarController.tabBar.items?.count ?? 1)"
        }
    }
    
    /// Sets up accessibility for alert controllers
    static func configureAlertController(_ alertController: UIAlertController) {
        // Configure alert title and message
        if let title = alertController.title {
            alertController.setValue(title, forKey: "accessibilityLabel")
        }
        
        if let message = alertController.message {
            alertController.setValue(message, forKey: "accessibilityValue")
        }
        
        // Configure alert actions
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
    
    /// Sets up accessibility for text views
    static func configureTextView(_ textView: UITextView, placeholder: String? = nil) {
        textView.accessibilityTraits = [.keyboardKey]
        textView.adjustsFontForContentSizeCategory = true
        
        if let placeholder = placeholder {
            textView.accessibilityHint = placeholder
        }
    }
    
    /// Sets up accessibility for scroll views
    static func configureScrollView(_ scrollView: UIScrollView, contentDescription: String? = nil) {
        scrollView.accessibilityTraits = [.none]
        
        if let description = contentDescription {
            scrollView.accessibilityLabel = description
        }
        
        // Enable accessibility for scroll indicators
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
    }
    
    /// Sets up accessibility for page controls
    static func configurePageControl(_ pageControl: UIPageControl, description: String = "Page indicator") {
        pageControl.accessibilityLabel = description
        pageControl.accessibilityTraits = [.adjustable]
        pageControl.accessibilityHint = "Swipe left or right to change pages"
    }
    
    /// Sets up accessibility for image views
    static func configureImageView(_ imageView: UIImageView, description: String?, isDecorative: Bool = false) {
        if isDecorative {
            imageView.isAccessibilityElement = false
            imageView.accessibilityElementsHidden = true
        } else {
            imageView.isAccessibilityElement = true
            imageView.accessibilityLabel = description
            imageView.accessibilityTraits = [.image]
        }
    }
    
    /// Sets up accessibility for activity indicators
    static func configureActivityIndicator(_ activityIndicator: UIActivityIndicatorView, loadingMessage: String = "Loading") {
        activityIndicator.accessibilityLabel = loadingMessage
        activityIndicator.accessibilityTraits = [.notEnabled]
    }
    
    /// Sets up accessibility for progress views
    static func configureProgressView(_ progressView: UIProgressView, description: String, currentValue: Float? = nil) {
        progressView.accessibilityLabel = description
        progressView.accessibilityTraits = [.updatesFrequently]
        
        if let value = currentValue {
            let percentage = Int(value * 100)
            progressView.accessibilityValue = "\(percentage) percent complete"
        }
    }
    
    /// Sets up accessibility for steppers
    static func configureStepper(_ stepper: UIStepper, label: String, unit: String = "") {
        stepper.accessibilityLabel = label
        stepper.accessibilityTraits = [.adjustable]
        
        let currentValue = stepper.value
        stepper.accessibilityValue = "\(currentValue) \(unit)".trimmingCharacters(in: .whitespaces)
        stepper.accessibilityHint = "Swipe up to increase, swipe down to decrease"
    }
    
    /// Sets up accessibility for sliders
    static func configureSlider(_ slider: UISlider, label: String, unit: String = "", range: String? = nil) {
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

/// Extension for UIFont to provide accessibility-aware font scaling
extension UIFont {
    
    /// Creates a font that scales with Dynamic Type settings
    static func accessibleFont(size: CGFloat, weight: UIFont.Weight = .regular, maxSize: CGFloat? = nil) -> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        
        if let maxSize = maxSize {
            return UIFontMetrics.default.scaledFont(for: font, maximumPointSize: maxSize)
        } else {
            return UIFontMetrics.default.scaledFont(for: font)
        }
    }
    
    /// Creates a custom font with Dynamic Type support
    static func accessibleCustomFont(name: String, size: CGFloat, maxSize: CGFloat? = nil) -> UIFont? {
        guard let customFont = UIFont(name: name, size: size) else {
            // Fallback to system font
            return accessibleFont(size: size, maxSize: maxSize)
        }
        
        if let maxSize = maxSize {
            return UIFontMetrics.default.scaledFont(for: customFont, maximumPointSize: maxSize)
        } else {
            return UIFontMetrics.default.scaledFont(for: customFont)
        }
    }
}

/// Extension for UIColor to provide accessibility utilities
extension UIColor {
    
    /// Creates a color from hex string (for brand colors)
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
    
    /// Checks if this color has sufficient contrast with another color
    func hasAccessibleContrast(with otherColor: UIColor, isLargeText: Bool = false) -> Bool {
        return AccessibilityUtils.meetsWCAGAA(foreground: self, background: otherColor, isLargeText: isLargeText)
    }
}