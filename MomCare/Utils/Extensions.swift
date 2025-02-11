//
//  Extensions.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/02/25.
//

import Foundation
import UIKit
import CoreImage.CIFilterBuiltins

extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
    }

    func isNumeric() -> Bool {
        return Double(self) != nil
    }
}

extension UIImage {
    // https://stackoverflow.com/questions/79194950/get-dominant-color-from-image-in-swiftui

    func dominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let filter = CIFilter.areaAverage()
        filter.inputImage = inputImage
        filter.extent = inputImage.extent // Use CGRect directly

        let context = CIContext()
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4) // RGBA format
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1), // 1x1 pixel
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: CGFloat(bitmap[3]) / 255.0
        )
    }
}

extension Encodable {
    func toDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }

        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }

    func toData(keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }
}

extension Date {
    func relativeString(from date: Date?) -> String {
        guard let date else { return "just now" }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth, .month, .year]
        formatter.maximumUnitCount = 1

        let now = Date()
        let timeInterval = round(now.timeIntervalSince(date))

        if let formattedString = formatter.string(from: abs(timeInterval)) {
            return timeInterval < 0 ? "in \(formattedString)" : "\(formattedString) ago"
        } else {
            return "just now"
        }
    }
    
    func relativeInterval(from date: Date?) -> TimeInterval {
        guard let date else { return 0 }
        return abs(round(Date().timeIntervalSince(date)))
    }
}
