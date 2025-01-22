import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var actionButton: UIButton!

    @IBOutlet var mealHeaderLabel: UILabel!
    @IBOutlet var mealHeaderButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        configurePullDownMenu()
    }
    
    var section: Int?
    private let color = Converters.convertHexToUIColor(hex: "924350")

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
    
    func updateTitle(with title: String, at section: Int) {
        mealHeaderLabel.text = title
        self.section = section
    }

    @IBAction func mealHeaderButtonTapped(_ sender: UIButton) {
        switch section {
        case 0:
            MomCareUser.shared.diet.markFoodsAsConsumed(in: .breakfast)
        case 1:
            MomCareUser.shared.diet.markFoodsAsConsumed(in: .lunch)
        case 2:
            MomCareUser.shared.diet.markFoodsAsConsumed(in: .snacks)
        case 3:
            MomCareUser.shared.diet.markFoodsAsConsumed(in: .dinner)
        default:
            fatalError("pyar is khubsooaat cheez hai")
        }
        let configuration = UIImage.SymbolConfiguration(scale: .medium)
        mealHeaderButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)
    }
}
