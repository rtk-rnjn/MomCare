//
//  UIImage+Utils.swift
//  MomCare
//
//  Created by RITIK RANJAN on 18/06/25.
//

import UIKit

#if canImport(CoreImage)
import CoreImage.CIFilterBuiltins
#endif

extension UIImage {

    /// Computes the dominant color of the image.
    ///
    /// This method calculates the average color of all pixels in the image using CoreImage's
    /// `areaAverage` filter. The process is as follows:
    /// 1. Convert `UIImage` to `CIImage` for CoreImage processing.
    /// 2. Apply the `CIFilter.areaAverage()` filter to compute a 1x1 pixel image representing
    ///    the average color.
    /// 3. Render the 1x1 pixel image to a raw RGBA byte array.
    /// 4. Convert the RGBA bytes (0-255) into a `UIColor` (0.0-1.0 range).
    ///
    /// ### Notes
    /// - This is an efficient way to get a representative color of the image without analyzing
    ///   every pixel manually.
    /// - Requires CoreImage (`CIFilterBuiltins`) to work.
    ///
    /// - Returns: The most representative `UIColor` of the image, or `nil` if CoreImage is
    ///            unavailable or the operation fails.
    func dominantColor() -> UIColor? {
#if canImport(CoreImage)
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
#else
        return nil
#endif
    }

    /// Fetches an image from a given URI string asynchronously.
    ///
    /// - Parameters:
    ///   - imageUri: The remote image URI to fetch.
    ///   - defaultImage: An optional placeholder image to return if fetching fails.
    /// - Returns: The fetched `UIImage` if successful, otherwise `defaultImage`.
    ///
    /// ### Notes
    /// - Uses `CacheHandler` to attempt fetching from cache or network.
    /// - Returns immediately with `defaultImage` if `imageUri` is invalid.
    func fetchImage(from imageUri: String?, default defaultImage: UIImage? = nil) async -> UIImage? {
        guard let imageUri, let url = URL(string: imageUri) else {
            return defaultImage
        }

        let fetchedImage = await CacheHandler.shared.fetchImage(from: url)
        return fetchedImage ?? defaultImage
    }
}
