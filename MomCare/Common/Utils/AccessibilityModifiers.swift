//
//  AccessibilityModifiers.swift
//  MomCare
//
//  Created by Copilot on 14/09/2024.
//

import SwiftUI

/// View modifier to ensure minimum touch target sizes for accessibility
struct MinimumTouchTarget: ViewModifier {
    private let minimumSize: CGFloat = 44 // Apple's recommended minimum touch target size
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: minimumSize, minHeight: minimumSize)
    }
}

/// View modifier to add accessible focus ring for custom controls
struct AccessibleFocusRing: ViewModifier {
    @Environment(\.isFocused) private var isFocused
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: isFocused ? 3 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
    }
}

/// View modifier for enhanced button accessibility
struct AccessibleButton: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits
    
    init(label: String, hint: String? = nil, traits: AccessibilityTraits = []) {
        self.label = label
        self.hint = hint
        self.traits = traits
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(MinimumTouchTarget())
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits([.isButton] + traits)
    }
}

/// View modifier for enhanced text accessibility
struct AccessibleText: ViewModifier {
    let role: AccessibilityRole
    let traits: AccessibilityTraits
    
    init(role: AccessibilityRole = .text, traits: AccessibilityTraits = []) {
        self.role = role
        self.traits = traits
    }
    
    func body(content: Content) -> some View {
        content
            .accessibilityAddTraits(traits)
    }
}

// Extension to easily apply modifiers
extension View {
    /// Ensures minimum touch target size for accessibility
    func minimumTouchTarget() -> some View {
        modifier(MinimumTouchTarget())
    }
    
    /// Adds accessible focus ring for custom controls
    func accessibleFocusRing() -> some View {
        modifier(AccessibleFocusRing())
    }
    
    /// Enhanced accessibility for buttons
    func accessibleButton(label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        modifier(AccessibleButton(label: label, hint: hint, traits: traits))
    }
    
    /// Enhanced accessibility for text elements
    func accessibleText(role: AccessibilityRole = .text, traits: AccessibilityTraits = []) -> some View {
        modifier(AccessibleText(role: role, traits: traits))
    }
    
    /// Quick modifier for header text
    func accessibleHeader() -> some View {
        accessibleText(traits: .isHeader)
    }
    
    /// Quick modifier for static text
    func accessibleStaticText() -> some View {
        accessibleText(traits: .isStaticText)
    }
}