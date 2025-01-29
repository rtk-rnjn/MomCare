//
//  PlayerViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 29/01/25.
//

import UIKit
import CoreImage

class PlayerViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet var playerImageViewOutlet: UIImageView!

    let gradientLayer = CAGradientLayer()

        override func viewDidLoad() {
            super.viewDidLoad()

            updateUIForNewSong(songImage: UIImage(named: "fantasize")!)
        }

    func updateGradientBackground(with color: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        let lighterColor = color.withAlphaComponent(0.5).cgColor
        let darkerColor = color.withAlphaComponent(0.9).cgColor

        gradientLayer.colors = [lighterColor, darkerColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func updateUIForNewSong(songImage: UIImage) {
        if let dominantColor = songImage.dominantColor() {
            updateGradientBackground(with: dominantColor)
        }
    }
}

extension UIImage {
    func dominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extent = inputImage.extent
        let filter = CIFilter(name: "CIAreaAverage",
                               parameters: [kCIInputImageKey: inputImage,
                                            kCIInputExtentKey: CIVector(cgRect: extent)])

        guard let outputImage = filter?.outputImage else { return nil }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        return UIColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: 1.0)
    }
}
