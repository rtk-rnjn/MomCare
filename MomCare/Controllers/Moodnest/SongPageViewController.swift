import UIKit

class SongPageViewController: UIViewController {
    
    @IBOutlet var upperContainer: UIView!
    @IBOutlet var lowerContainer: UIView!
    
    // Gradient layers for both containers
    private let upperGradientLayer = CAGradientLayer()
    private let lowerGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure gradients
        configureGradientForUpperContainer()
        configureGradientForLowerContainer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the gradient layers' frames to match the containers
        upperGradientLayer.frame = upperContainer.bounds
        lowerGradientLayer.frame = lowerContainer.bounds
    }
    
    private func configureGradientForUpperContainer() {
        upperGradientLayer.colors = [Converters.convertHexToUIColor(hex: "#8c5c76").cgColor]
        upperGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        upperGradientLayer.endPoint = CGPoint(x: 0, y: 1) // Vertical gradient
        upperContainer.layer.insertSublayer(upperGradientLayer, at: 0)
    }
    
    private func configureGradientForLowerContainer() {
        lowerGradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor // Light gray
        ]
        lowerGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        lowerGradientLayer.endPoint = CGPoint(x: 0, y: 1) // Vertical gradient
        lowerContainer.layer.insertSublayer(lowerGradientLayer, at: 0)
    }
}
