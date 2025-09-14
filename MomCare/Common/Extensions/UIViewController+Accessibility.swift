//
//  UIViewController+Accessibility.swift
//  MomCare
//
//  Created by Copilot on 14/09/2024.
//

import UIKit

/// Extension providing accessibility utilities for UIViewController
extension UIViewController {
    
    /// Sets up basic accessibility properties for the view controller
    func setupBasicAccessibility(title: String? = nil) {
        // Set navigation accessibility
        if let navigationController = navigationController {
            navigationController.navigationBar.isAccessibilityElement = false
            
            // Set title for screen reader
            if let titleText = title ?? self.title {
                navigationItem.accessibilityLabel = titleText
            }
        }
        
        // Set up back button accessibility
        navigationItem.backBarButtonItem?.accessibilityLabel = "Back"
        navigationItem.backBarButtonItem?.accessibilityHint = "Navigate back to previous screen"
        
        // Announce screen changes to VoiceOver
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIAccessibility.post(notification: .screenChanged, argument: self.view)
            }
        }
    }
    
    /// Configures accessibility for form fields
    func setupFormAccessibility(fields: [(textField: UITextField, label: String, hint: String?)]) {
        for field in fields {
            field.textField.accessibilityLabel = field.label
            field.textField.accessibilityHint = field.hint
            field.textField.adjustsFontForContentSizeCategory = true
            
            // Ensure proper keyboard type accessibility
            switch field.textField.keyboardType {
            case .emailAddress:
                field.textField.accessibilityTraits = [.keyboardKey]
                field.textField.textContentType = .emailAddress
            case .numberPad, .decimalPad:
                field.textField.accessibilityTraits = [.keyboardKey]
            default:
                field.textField.accessibilityTraits = [.keyboardKey]
            }
        }
    }
    
    /// Configures accessibility for buttons
    func setupButtonAccessibility(buttons: [(button: UIButton, label: String, hint: String?)]) {
        for buttonInfo in buttons {
            let button = buttonInfo.button
            button.accessibilityLabel = buttonInfo.label
            button.accessibilityHint = buttonInfo.hint
            button.accessibilityTraits = [.button]
            
            // Ensure minimum touch target size
            button.minimumTouchTargetSize = CGSize(width: 44, height: 44)
            
            // Enable Dynamic Type
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.titleLabel?.numberOfLines = 0
        }
    }
    
    /// Configures accessibility for collection/table view cells
    func setupCellAccessibility(for cell: UIView, label: String, hint: String? = nil, traits: UIAccessibilityTraits = []) {
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = label
        cell.accessibilityHint = hint
        cell.accessibilityTraits = traits.isEmpty ? [.button] : traits
    }
    
    /// Sets up accessibility for custom controls
    func setupCustomControlAccessibility(control: UIView, label: String, hint: String? = nil, value: String? = nil) {
        control.isAccessibilityElement = true
        control.accessibilityLabel = label
        control.accessibilityHint = hint
        control.accessibilityValue = value
        control.accessibilityTraits = [.adjustable]
    }
    
    /// Announces important updates to VoiceOver users
    func announceAccessibilityUpdate(_ message: String, priority: UIAccessibilityNotifications = .announcement) {
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: priority, argument: message)
        }
    }
    
    /// Sets up accessibility for segmented controls
    func setupSegmentedControlAccessibility(control: UISegmentedControl, label: String) {
        control.accessibilityLabel = label
        control.accessibilityTraits = [.adjustable]
        
        // Set up individual segment labels
        for index in 0..<control.numberOfSegments {
            if let title = control.titleForSegment(at: index) {
                control.setAccessibilityLabel(title, forSegmentAt: index)
            }
        }
    }
    
    /// Sets up accessibility for date pickers
    func setupDatePickerAccessibility(picker: UIDatePicker, label: String, hint: String? = nil) {
        picker.accessibilityLabel = label
        picker.accessibilityHint = hint ?? "Swipe up or down to adjust the date"
        picker.accessibilityTraits = [.adjustable]
    }
    
    /// Sets up accessibility for switches
    func setupSwitchAccessibility(switches: [(switch: UISwitch, label: String, hint: String?)]) {
        for switchInfo in switches {
            let switchControl = switchInfo.switch
            switchControl.accessibilityLabel = switchInfo.label
            switchControl.accessibilityHint = switchInfo.hint
            switchControl.accessibilityTraits = [.button]
        }
    }
    
    /// Validates color contrast for the view controller's theme
    func validateColorContrast() {
        #if DEBUG
        AccessibilityUtils.validateAppColors()
        #endif
    }
}

/// Extension for UIButton to ensure minimum touch target size
extension UIButton {
    var minimumTouchTargetSize: CGSize {
        get {
            return frame.size
        }
        set {
            let horizontalPadding = max(0, newValue.width - frame.width) / 2
            let verticalPadding = max(0, newValue.height - frame.height) / 2
            
            contentEdgeInsets = UIEdgeInsets(
                top: verticalPadding,
                left: horizontalPadding,
                bottom: verticalPadding,
                right: horizontalPadding
            )
        }
    }
}

/// Extension for UIView to provide accessibility utilities
extension UIView {
    
    /// Makes the view accessible with basic configuration
    func makeAccessible(label: String, hint: String? = nil, traits: UIAccessibilityTraits = []) {
        isAccessibilityElement = true
        accessibilityLabel = label
        accessibilityHint = hint
        accessibilityTraits = traits
    }
    
    /// Hides decorative elements from VoiceOver
    func hideFromAccessibility() {
        isAccessibilityElement = false
        accessibilityElementsHidden = true
    }
    
    /// Groups related accessibility elements
    func groupAccessibilityElements(_ elements: [UIView], label: String? = nil) {
        isAccessibilityElement = false
        accessibilityElements = elements
        
        if let groupLabel = label {
            accessibilityLabel = groupLabel
        }
    }
}

/// Extension for UILabel to enable Dynamic Type
extension UILabel {
    
    /// Enables Dynamic Type support for the label
    func enableDynamicType() {
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
    }
    
    /// Sets up accessibility for informational labels
    func setupInformationalAccessibility(importance: AccessibilityImportance = .medium) {
        enableDynamicType()
        
        switch importance {
        case .high:
            accessibilityTraits = [.header]
        case .medium:
            accessibilityTraits = [.staticText]
        case .low:
            accessibilityTraits = [.none]
            // For low importance, consider hiding from VoiceOver if it's purely decorative
        }
    }
}

/// Enum for accessibility importance levels
enum AccessibilityImportance {
    case high    // Headers, important information
    case medium  // Regular content
    case low     // Decorative or supplementary content
}