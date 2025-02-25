//
//  MoodsViewController.swift
//  MomCare
//
//  Created by Batch - 2  on 16/01/25.
//

import UIKit
import ImageIO

class MoodsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var emotionsScrollView: UIScrollView!

    @IBOutlet var happyImageView: UIImageView!
    @IBOutlet var sadImageView: UIImageView!
    @IBOutlet var stressedImageView: UIImageView!
    @IBOutlet var angryImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        emotionsScrollView.delegate = self
        emotionsScrollView.isPagingEnabled = true
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        
        
        happyImageView.image = loadGIF(named: "happy")
        sadImageView.image = loadGIF(named: "sad")
        stressedImageView.image = loadGIF(named: "stressed")
        angryImageView.image = loadGIF(named: "angry")


        happyImageView.isUserInteractionEnabled = true
        sadImageView.isUserInteractionEnabled = true
        stressedImageView.isUserInteractionEnabled = true
        angryImageView.isUserInteractionEnabled = true

        addTapGesture(to: happyImageView)
        addTapGesture(to: sadImageView)
        addTapGesture(to: stressedImageView)
        addTapGesture(to: angryImageView)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "segueShowMoodNestViewController" {
            if let destination = segue.destination as? MoodNestViewController,
               let selectedImageView = sender as? UIImageView {
                destination.iconImageView = selectedImageView.image
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(emotionsScrollView.contentOffset.x / emotionsScrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

    func addTapGesture(to imageView: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let tappedImageView = sender.view as? UIImageView {
            performSegue(withIdentifier: "segueShowMoodNestViewController", sender: tappedImageView)
        }
    }
    
    func loadGIF(named name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        
        return UIImage.gif(data: data)
    }

}

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        
        var images: [UIImage] = []
        var totalDuration: TimeInterval = 0

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let frameDuration = UIImage.frameDuration(from: source, at: i)
                totalDuration += frameDuration
                images.append(UIImage(cgImage: cgImage))
            }
        }

        return UIImage.animatedImage(with: images, duration: totalDuration)
    }

    private static func frameDuration(from source: CGImageSource, at index: Int) -> TimeInterval {
        let defaultFrameDuration = 0.1
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
              let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
                ?? gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval else {
            return defaultFrameDuration
        }
        return delayTime < 0.01 ? defaultFrameDuration : delayTime
    }
}
