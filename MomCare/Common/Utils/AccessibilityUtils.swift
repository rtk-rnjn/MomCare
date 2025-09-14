//
//  AccessibilityUtils.swift
//  MomCare
//
//  Created by Copilot on 14/09/2024.
//

import UIKit
import SwiftUI

/// Utility class for accessibility-related functionality
class AccessibilityUtils {
    
    /// Calculates the contrast ratio between two colors
    /// - Parameters:
    ///   - color1: First color
    ///   - color2: Second color  
    /// - Returns: Contrast ratio value (1-21)
    static func contrastRatio(between color1: UIColor, and color2: UIColor) -> CGFloat {
        let luminance1 = relativeLuminance(of: color1)
        let luminance2 = relativeLuminance(of: color2)
        
        let lighter = max(luminance1, luminance2)
        let darker = min(luminance1, luminance2)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Checks if the contrast ratio meets WCAG AA standards (4.5:1 for normal text, 3:1 for large text)
    /// - Parameters:
    ///   - foreground: Foreground color
    ///   - background: Background color
    ///   - isLargeText: Whether the text is considered large (18pt+ or 14pt+ bold)
    /// - Returns: True if contrast meets WCAG AA standards
    static func meetsWCAGAA(foreground: UIColor, background: UIColor, isLargeText: Bool = false) -> Bool {
        let ratio = contrastRatio(between: foreground, and: background)
        return ratio >= (isLargeText ? 3.0 : 4.5)
    }
    
    /// Checks if the contrast ratio meets WCAG AAA standards (7:1 for normal text, 4.5:1 for large text)
    /// - Parameters:
    ///   - foreground: Foreground color
    ///   - background: Background color
    ///   - isLargeText: Whether the text is considered large (18pt+ or 14pt+ bold)
    /// - Returns: True if contrast meets WCAG AAA standards
    static func meetsWCAGAAA(foreground: UIColor, background: UIColor, isLargeText: Bool = false) -> Bool {
        let ratio = contrastRatio(between: foreground, and: background)
        return ratio >= (isLargeText ? 4.5 : 7.0)
    }
    
    /// Calculates the relative luminance of a color
    /// - Parameter color: The color to calculate luminance for
    /// - Returns: Relative luminance value (0-1)
    private static func relativeLuminance(of color: UIColor) -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Convert to linear RGB
        func linearRGB(_ component: CGFloat) -> CGFloat {
            if component <= 0.03928 {
                return component / 12.92
            } else {
                return pow((component + 0.055) / 1.055, 2.4)
            }
        }
        
        let linearRed = linearRGB(red)
        let linearGreen = linearRGB(green)
        let linearBlue = linearRGB(blue)
        
        // Calculate relative luminance
        return 0.2126 * linearRed + 0.7152 * linearGreen + 0.0722 * linearBlue
    }
    
    /// Validates common color combinations used in the app
    static func validateAppColors() {
        let brandColor = UIColor(hex: "#924350") // Main brand color
        let backgroundColor = UIColor.systemBackground
        let secondaryBackground = UIColor.secondarySystemBackground
        let whiteBackground = UIColor.white
        
        print("=== MomCare Color Contrast Validation ===")
        
        // Test brand color on white background
        let brandOnWhite = contrastRatio(between: brandColor, and: whiteBackground)
        print("Brand color (#924350) on white: \(String(format: "%.2f", brandOnWhite)):1 - \(meetsWCAGAA(foreground: brandColor, background: whiteBackground) ? "✅ WCAG AA" : "❌ WCAG AA")")
        
        // Test brand color on system background
        let brandOnSystem = contrastRatio(between: brandColor, and: backgroundColor)
        print("Brand color on system background: \(String(format: "%.2f", brandOnSystem)):1 - \(meetsWCAGAA(foreground: brandColor, background: backgroundColor) ? "✅ WCAG AA" : "❌ WCAG AA")")
        
        // Test secondary text color
        let secondaryText = UIColor.secondaryLabel
        let secondaryOnWhite = contrastRatio(between: secondaryText, and: whiteBackground)
        print("Secondary text on white: \(String(format: "%.2f", secondaryOnWhite)):1 - \(meetsWCAGAA(foreground: secondaryText, background: whiteBackground) ? "✅ WCAG AA" : "❌ WCAG AA")")
        
        print("========================================")
    }
}

// SwiftUI Color extension for contrast checking
extension Color {
    /// Converts SwiftUI Color to UIColor for contrast calculations
    var uiColor: UIColor {
        return UIColor(self)
    }
    
    /// Checks contrast ratio with another color
    func contrastRatio(with other: Color) -> CGFloat {
        return AccessibilityUtils.contrastRatio(between: self.uiColor, and: other.uiColor)
    }
    
    /// Checks if contrast meets WCAG AA standards
    func meetsWCAGAA(with background: Color, isLargeText: Bool = false) -> Bool {
        return AccessibilityUtils.meetsWCAGAA(foreground: self.uiColor, background: background.uiColor, isLargeText: isLargeText)
    }
}