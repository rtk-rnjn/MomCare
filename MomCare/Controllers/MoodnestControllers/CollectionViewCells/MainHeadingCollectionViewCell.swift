import UIKit

class MainHeadingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var mainHeadingLabel: UILabel!

    func updateElements(with label: String) {
        let text = label
        mainHeadingLabel.text = text
        mainHeadingLabel.accessibilityLabel = text
        mainHeadingLabel.accessibilityHint = "Quote based on your current selection of mood"
        
        // Apply Dynamic Type
        mainHeadingLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        mainHeadingLabel.adjustsFontForContentSizeCategory = true
        
        // Configure cell accessibility
        isAccessibilityElement = true
        accessibilityLabel = "Mood quote: \(text)"
        accessibilityHint = "Quote based on your current selection of mood"
        accessibilityTraits = .staticText
    }
}
