import UIKit

class MainHeadingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var mainHeadingLabel: UILabel!

    func updateMainHeading(with indexPath: IndexPath) {
        let text = "Take a moment to rewind with \"\(SampleFeaturedPlaylists.playlists[indexPath.row].name)\" playlists"
        mainHeadingLabel.text = text
    }
}
