//
//  UIColor+Hex.swift
//  MomCare
//
//  Created by RITIK RANJAN on 28/09/25.
//

import UIKit

extension UIColor {
    /// Initializes a `UIColor` object from a hex string and optional alpha value.
    ///
    /// Supports 3-digit (`"F00"`), 6-digit (`"FF0000"`), and 8-digit (`"FFFF0000"`) hex strings.
    /// Defaults to black color if the input is invalid.
    ///
    /// - Parameters:
    ///   - hex: The hex string representing the color. Can optionally start with `#`.
    ///   - alpha: The alpha value to apply if the hex string does not specify it (default is 1.0).
    ///
    /// ### Usage
    /// ```swift
    /// let color1 = UIColor(hex: "#F00")       // Red
    /// let color2 = UIColor(hex: "FF0000")     // Red
    /// let color3 = UIColor(hex: "80FF0000")   // Semi-transparent Red
    /// let color4 = UIColor(hex: "INVALID")    // Defaults to black
    /// ```
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var hexValue: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&hexValue) else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }

        let redComponent, greenComponent, blueComponent, alphaComponent: CGFloat

        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            redComponent = CGFloat((hexValue >> 8) & 0xF) * 17 / 255.0
            greenComponent = CGFloat((hexValue >> 4) & 0xF) * 17 / 255.0
            blueComponent = CGFloat(hexValue & 0xF) * 17 / 255.0
            alphaComponent = alpha

        case 6: // RRGGBB (24-bit)
            redComponent = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            greenComponent = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            blueComponent = CGFloat(hexValue & 0xFF) / 255.0
            alphaComponent = alpha

        case 8: // AARRGGBB (32-bit)
            alphaComponent = CGFloat((hexValue >> 24) & 0xFF) / 255.0
            redComponent = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            greenComponent = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            blueComponent = CGFloat(hexValue & 0xFF) / 255.0

        default:
            // Invalid hex string, default to black
            redComponent = 0; greenComponent = 0; blueComponent = 0; alphaComponent = alpha
        }

        self.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
    }
}
