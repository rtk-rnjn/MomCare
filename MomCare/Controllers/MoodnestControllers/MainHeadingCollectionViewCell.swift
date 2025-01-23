import UIKit

class MainHeadingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainHeadingLabel: UILabel!

    func updateSection1(with indexPath: IndexPath) {
        let text = "Take a moment to rewind with \"\(FeaturedPlaylists.playlists[indexPath.row].name)\" playlists"

        // Get the preferred large title font and make it bold
        let baseFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        let boldFontDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) // Add bold trait
        let boldFont = UIFont(descriptor: boldFontDescriptor ?? baseFont.fontDescriptor, size: baseFont.pointSize)

        // Paragraph style for line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = -10

        // Combine bold font and paragraph style
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .paragraphStyle: paragraphStyle
        ]

        // Create attributed string and set it to the label
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        mainHeadingLabel.attributedText = attributedText
    }
}
