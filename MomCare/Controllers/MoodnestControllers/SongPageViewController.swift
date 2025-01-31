import UIKit

enum ContainerViewSegueIdentifier: String {
    case songPageTableVC = "embedShowSongPageTableViewController"
    case songPageElementsVC = "embedShowSongPageContainerViewController"
}

class SongPageViewController: UIViewController {

    @IBOutlet var upperContainer: UIView!
    @IBOutlet var lowerContainer: UIView!

    var playlist: Playlist!

    var songPageTableViewController: SongPageTableViewController?
    var songPageElementsViewController: SongPageElementsViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        let containerSegueIdentifier = ContainerViewSegueIdentifier(rawValue: identifier ?? "")
        switch containerSegueIdentifier {
        case .songPageTableVC:
            if let destination = segue.destination as? SongPageTableViewController {
                songPageTableViewController = destination
                songPageTableViewController?.playlist = playlist
            }
        case .songPageElementsVC:
            if let destination = segue.destination as? SongPageElementsViewController {
                songPageElementsViewController = destination
                songPageElementsViewController?.playlist = playlist
            }
        case .none:
            fatalError("should not happen, baby <3")
        }
    }
}
