import UIKit

enum ContainerViewSegueIdentifier: String {
    case songPageTableVC = "embedShowPlaylistTableViewController"
    case songPageElementsVC = "embedShowSongElementsViewController"
}

class SongPageViewController: UIViewController {

    @IBOutlet var upperContainer: UIView!
    @IBOutlet var lowerContainer: UIView!

    var playlist: (imageUri: String, label: String)?
    var playlistTableViewController: PlaylistTableViewController?
    var songElementsViewController: SongElementsViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        let containerSegueIdentifier = ContainerViewSegueIdentifier(rawValue: identifier ?? "")
        switch containerSegueIdentifier {
        case .songPageTableVC:
            if let destination = segue.destination as? PlaylistTableViewController {
                playlistTableViewController = destination
                playlistTableViewController?.playlist = playlist

                playlistTableViewController?.initialTabBarController = tabBarController as? InitialTabBarController
                playlistTableViewController?.songElementsViewController = songElementsViewController
            }

        case .songPageElementsVC:
            if let destination = segue.destination as? SongElementsViewController {
                songElementsViewController = destination
                songElementsViewController?.playlist = playlist
            }

        case .none:
            fatalError("should not happen, baby <3")
        }
    }
}
