//
//  UIImage+Utils.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import UIKit
import CoreImage.CIFilterBuiltins

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

    @MainActor
    func fetchImage(from imageUri: String?, default defaultImage: UIImage? = nil) async -> UIImage? {
        guard let imageUri, let url = URL(string: imageUri) else {
            return defaultImage
        }

        let fetchedImage = await CacheHandler.shared.fetchImage(from: url)
        return fetchedImage ?? defaultImage
    }
}
