//
//  Extensions.swift
//  MomCare
//
//  Created by RITIK RANJAN on 05/02/25.
//

import Foundation
import UIKit
import SwiftUI
import CoreImage.CIFilterBuiltins
import ObjectiveC
import OSLog

private let logger: Logger = .init(subsystem: "com.MomCare.Extension", category: "Extension")

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
        filter.extent = inputImage.extent

        let context = CIContext()
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
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

    @MainActor func fetchImage(from imageUri: String?, default defaultImage: UIImage? = nil) async -> UIImage? {
        guard let imageUri, let url = URL(string: imageUri) else {
            return defaultImage
        }

        let fetchedImage = await CacheHandler.shared.fetchImage(from: url)
        return fetchedImage ?? defaultImage
    }
}

extension Encodable {
    func toDictionary<T>(snakeCase: Bool = false) -> T? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }

        if snakeCase {
            encoder.keyEncodingStrategy = .convertToSnakeCase
        }

        do {
            return try JSONSerialization.jsonObject(with: data) as? T
        } catch {
            logger.error("Failed to convert object to dictionary: \(String(describing: error))")
            return nil
        }
    }

    func toData(keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        do {
            return try encoder.encode(self)
        } catch {
            logger.error("Failed to encode object: \(String(describing: error))")
            return nil
        }
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

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        // https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values

        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIButton {
    func startLoadingAnimation() {
        setTitle("", for: .normal)

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true

        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func stopLoadingAnimation(withRestoreLabel title: String) {
        setTitle(title, for: .normal)

        for subview in subviews where subview is UIActivityIndicatorView {
            subview.removeFromSuperview()
        }
    }
}

nonisolated(unsafe) private var shimmerLayerKey: UInt8 = 0
nonisolated(unsafe) private var shimmerIsShowingKey: UInt8 = 0

extension UIView {
    private var shimmerLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &shimmerLayerKey) as? CAGradientLayer
        }
        set {
            objc_setAssociatedObject(self, &shimmerLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var isShimmering: Bool {
        get {
            return (objc_getAssociatedObject(self, &shimmerIsShowingKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &shimmerIsShowingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func startShimmer(
        colors: [UIColor] = [
            UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0),
            UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        ],
        duration: TimeInterval = 0.5
    ) {
        guard !isShimmering else { return }
        isShimmering = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.name = "shimmerLayer"

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.5, 1]
        animation.toValue = [1, 1.5, 2]
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.autoreverses = true

        gradientLayer.add(animation, forKey: "shimmerAnimation")
        layer.addSublayer(gradientLayer)

        shimmerLayer = gradientLayer
    }

    func stopShimmer() {
        guard isShimmering else { return }
        isShimmering = false

        shimmerLayer?.removeAllAnimations()
        shimmerLayer?.removeFromSuperlayer()
        shimmerLayer = nil
    }

    func applyDefaultPriorities(priority: UILayoutPriority = .required) {
        self.setContentHuggingPriority(priority, for: .horizontal)
        self.setContentHuggingPriority(priority, for: .vertical)
        self.setContentCompressionResistancePriority(priority, for: .horizontal)
        self.setContentCompressionResistancePriority(priority, for: .vertical)
    }

}

extension Data {
    func decode<T: Codable>() -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            logger.error("Failed to decode data: \(String(describing: error))")
            return nil
        }
    }
}

extension Color {
    init(hex: String) {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
