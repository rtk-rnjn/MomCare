//
//  UIViewController+Accessibility.swift
//  MomCare
//
//  Created by Copilot on 14/09/2024.
//

import UIKit

/// Extension providing accessibility utilities for UIViewController
extension UIViewController {
    
    func setupBasicAccessibility(title: String? = nil) {
        if let navigationController = navigationController {
            navigationController.navigationBar.isAccessibilityElement = false
            
            if let titleText = title ?? self.title {
                navigationItem.accessibilityLabel = titleText
            }
        }
        
        navigationItem.backBarButtonItem?.accessibilityLabel = "Back"
        navigationItem.backBarButtonItem?.accessibilityHint = "Navigate back to previous screen"
        
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIAccessibility.post(notification: .screenChanged, argument: self.view)
            }
        }
    }
    
    func setupFormAccessibilityForTextFields(fields: [(textField: UITextField, label: String, hint: String?)]) {
        for field in fields {
            field.textField.accessibilityLabel = field.label
            field.textField.accessibilityHint = field.hint
            field.textField.adjustsFontForContentSizeCategory = true
            
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
    
    func setupButtonAccessibilityWithMinimumTouchTargets(buttons: [(button: UIButton, label: String, hint: String?)]) {
        for buttonInfo in buttons {
            let button = buttonInfo.button
            button.accessibilityLabel = buttonInfo.label
            button.accessibilityHint = buttonInfo.hint
            button.accessibilityTraits = [.button]
            
            button.minimumTouchTargetSize = CGSize(width: 44, height: 44)
            
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.titleLabel?.numberOfLines = 0
        }
    }
    
    func configureCollectionOrTableCellAccessibility(for cell: UIView, label: String, hint: String? = nil, traits: UIAccessibilityTraits = []) {
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = label
        cell.accessibilityHint = hint
        cell.accessibilityTraits = traits.isEmpty ? [.button] : traits
    }
    
    func configureAdjustableCustomControlAccessibility(control: UIView, label: String, hint: String? = nil, value: String? = nil) {
        control.isAccessibilityElement = true
        control.accessibilityLabel = label
        control.accessibilityHint = hint
        control.accessibilityValue = value
        control.accessibilityTraits = [.adjustable]
    }
    
    func announceAccessibilityUpdate(_ message: String, priority: UIAccessibilityNotifications = .announcement) {
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: priority, argument: message)
        }
    }
    
    func setupSegmentedControlAccessibilityWithIndividualLabels(control: UISegmentedControl, label: String) {
        control.accessibilityLabel = label
        control.accessibilityTraits = [.adjustable]
        
        for index in 0..<control.numberOfSegments {
            if let title = control.titleForSegment(at: index) {
                control.setAccessibilityLabel(title, forSegmentAt: index)
            }
        }
    }
    
    func setupDatePickerAccessibilityWithSwipeHints(picker: UIDatePicker, label: String, hint: String? = nil) {
        picker.accessibilityLabel = label
        picker.accessibilityHint = hint ?? "Swipe up or down to adjust the date"
        picker.accessibilityTraits = [.adjustable]
    }
    
    func setupSwitchAccessibilityWithButtonTraits(switches: [(switch: UISwitch, label: String, hint: String?)]) {
        for switchInfo in switches {
            let switchControl = switchInfo.switch
            switchControl.accessibilityLabel = switchInfo.label
            switchControl.accessibilityHint = switchInfo.hint
            switchControl.accessibilityTraits = [.button]
        }
    }
    
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
    
    func makeAccessibleWithCustomTraits(label: String, hint: String? = nil, traits: UIAccessibilityTraits = []) {
        isAccessibilityElement = true
        accessibilityLabel = label
        accessibilityHint = hint
        accessibilityTraits = traits
    }
    
    func hideDecorativeElementsFromAccessibility() {
        isAccessibilityElement = false
        accessibilityElementsHidden = true
    }
    
    func groupAccessibilityElementsWithOptionalLabel(_ elements: [UIView], label: String? = nil) {
        isAccessibilityElement = false
        accessibilityElements = elements
        
        if let groupLabel = label {
            accessibilityLabel = groupLabel
        }
    }
}

/// Extension for UILabel to enable Dynamic Type
extension UILabel {
    
    func enableDynamicTypeWithMultilineSupport() {
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
    }
    
    func setupInformationalAccessibilityByImportance(importance: AccessibilityImportance = .medium) {
        enableDynamicTypeWithMultilineSupport()
        
        switch importance {
        case .high:
            accessibilityTraits = [.header]
        case .medium:
            accessibilityTraits = [.staticText]
        case .low:
            accessibilityTraits = [.none]
        }
    }
}

enum AccessibilityImportance {
    case high    
    case medium  
    case low     
}