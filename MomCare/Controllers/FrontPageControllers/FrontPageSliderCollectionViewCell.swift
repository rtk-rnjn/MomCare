import UIKit

class FrontPageSliderCollectionViewCell: UICollectionViewCell {
    @IBOutlet var heading: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        // Enable Dynamic Type for heading
        heading.enableDynamicType()
        heading.setupInformationalAccessibility(importance: .high)
        
        // Configure image as decorative (will be overridden by collection view)
        imageView.isAccessibilityElement = false
        imageView.accessibilityElementsHidden = true
        
        // Group the cell elements
        isAccessibilityElement = true
        shouldGroupAccessibilityChildren = true
    }
    
    func configure(with title: String, image: UIImage?) {
        heading.text = title
        imageView.image = image
        
        // Update accessibility label when content changes
        var accessibilityText = title
        if image != nil {
            accessibilityText += ", with illustration"
        }
        
        accessibilityLabel = accessibilityText
        accessibilityTraits = [.staticText]
    }
}
