import UIKit

enum MealEditType: String {
    case addItem = "Add Item"
    case replaceItem = "Replace Item"
}

class HeaderTableViewCell: UITableViewCell {

    // MARK: Internal

    @IBOutlet var actionButton: UIButton!

    @IBOutlet var mealHeaderLabel: UILabel!
    @IBOutlet var mealHeaderButton: UIButton!

    var section: Int?
    var dietTableViewController: DietTableViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        configurePullDownMenu()
    }

    func updateTitle(with title: String, at section: Int, of view: DietTableViewController) {
        mealHeaderLabel.text = title
        self.section = section
        dietTableViewController = view
    }

    @IBAction func mealHeaderButtonTapped(_ sender: UIButton) {
        switch section {
        case 0:
            MomCareUser.shared.markFoodsAsConsumed(in: .breakfast)
        case 1:
            MomCareUser.shared.markFoodsAsConsumed(in: .lunch)
        case 2:
            MomCareUser.shared.markFoodsAsConsumed(in: .snacks)
        case 3:
            MomCareUser.shared.markFoodsAsConsumed(in: .dinner)
        default:
            fatalError("pyar is khubsooaat cheez hai")
        }
        let configuration = UIImage.SymbolConfiguration(scale: .medium)
        sender.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)

        dietTableViewController?.dietViewController.refresh()
    }

    // MARK: Private

    private let color: UIColor = Converters.convertHexToUIColor(hex: "924350")

    private func configurePullDownMenu() {
        let addItem = UIAction(title: "Add Item", image: UIImage(systemName: "plus"), handler: addItemHandler)
        let replaceItem = UIAction(title: "Replace Item", image: UIImage(systemName: "repeat"), handler: replaceItemHandler)
        actionButton.menu = UIMenu(title: "", children: [addItem, replaceItem])
        actionButton.showsMenuAsPrimaryAction = true

        actionButton.setTitle(nil, for: .normal)
        actionButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
    }

    private func addItemHandler(_ action: UIAction) {
        dietTableViewController?.performSegueToSearch(with: MealEditType.addItem)
    }

    private func replaceItemHandler(_ action: UIAction) {
        dietTableViewController?.performSegueToSearch(with: MealEditType.replaceItem)
    }

}
