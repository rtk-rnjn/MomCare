//
//  Color+Hex.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import SwiftUI

extension Color {
    /// Initializes a `Color` from a hex string.
    ///
    /// This initializer accepts hex color codes in the following formats:
    /// - `#RGB` (3 characters, e.g. `#F0A`)
    /// - `#RRGGBB` (6 characters, e.g. `#FF00AA`)
    /// - `#AARRGGBB` (8 characters, e.g. `#CCFF00AA`)
    ///
    /// If the string is invalid, the color defaults to **opaque black** (`#000000`).
    ///
    /// - Parameter hex: A string containing the hex representation of the color.
    ///
    /// ### Usage
    /// ```swift
    /// let primary = Color(hex: "#3498db")     // Blue
    /// let accent = Color(hex: "F39C12")       // Orange
    /// let translucent = Color(hex: "803498db") // Semi-transparent blue
    /// let shorthand = Color(hex: "#0F0")       // Bright green
    /// ```
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64

        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )

        case 6:
            (alpha, red, green, blue) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        case 8:
            (alpha, red, green, blue) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
