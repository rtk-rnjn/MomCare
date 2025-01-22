import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        configurePullDownMenu()
    }

    private func configurePullDownMenu() {
        // Create menu items (SF Symbols)
        let addItem = UIAction(title: "Add Item", image: UIImage(systemName: "plus")) { _ in
            print("Add Item selected")
        }
        let replaceItem = UIAction(title: "Replace Item", image: UIImage(systemName: "repeat")) { _ in
            print("Replace Item selected")
            
        }
        actionButton.menu = UIMenu(title: "", children: [addItem, replaceItem])
        actionButton.showsMenuAsPrimaryAction = true

        actionButton.setTitle(nil, for: .normal)
        actionButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
    }
}
