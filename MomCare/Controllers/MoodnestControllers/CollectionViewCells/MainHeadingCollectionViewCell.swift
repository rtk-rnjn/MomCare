import UIKit

class MainHeadingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var mainHeadingLabel: UILabel!

    func updateElements(with label: String) {

        let text = label

        mainHeadingLabel.text = text

        mainHeadingLabel.accessibilityLabel = text

        mainHeadingLabel.accessibilityHint = "Quote based on your current selection of mood"

    }

}
