//
//  Converters.swift
//  MomCare
//
//  Created by Ritik Ranjan on 18/01/25.
//

import Foundation
import UIKit

class Converters {
    static func convertHexToUIColor(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        /* https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values */

        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
