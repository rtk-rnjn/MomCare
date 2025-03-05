import UIKit

enum MealEditType: String {
    case addItem = "Add Item"
}

class HeaderTableViewCell: UITableViewCell {

    // MARK: Internal

    @IBOutlet var actionButton: UIButton!

    @IBOutlet var mealHeaderLabel: UILabel!
    @IBOutlet var mealHeaderButton: UIButton!

    var buttonTapHandler: (() -> Bool)?
    var segueHandler: (() -> Void)?
    var refreshHandler: (() -> Void)?
    var allConsumed: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()

        DispatchQueue.main.async {
            self.configurePullDownMenu()
        }
    }

    func updateElements(with title: String, segueHandler: (() -> Void)?, refreshHandler: (() -> Void)?, allConsumed: Bool, buttonTapHandler: @escaping (() -> Bool)) {
        mealHeaderLabel.text = title

        self.buttonTapHandler = buttonTapHandler
        self.segueHandler = segueHandler
        self.refreshHandler = refreshHandler
        self.allConsumed = allConsumed

        let configuration = UIImage.SymbolConfiguration(scale: .medium)

        if self.allConsumed {
            mealHeaderButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        } else {
            mealHeaderButton.setImage(UIImage(systemName: "circle", withConfiguration: configuration)?.withTintColor(color), for: .normal)
        }
    }

    @IBAction func mealHeaderButtonTapped(_ sender: UIButton) {
        let consumed = buttonTapHandler?() ?? false

        allConsumed = consumed

        refreshHandler?()
    }

    // MARK: Private

    private let color: UIColor = .init(hex: "924350")

    private func configurePullDownMenu() {
        let addItem = UIAction(title: "Add Item", image: UIImage(systemName: "plus"), handler: addItemHandler)
        actionButton.menu = UIMenu(title: "", children: [addItem])
        actionButton.showsMenuAsPrimaryAction = true

        actionButton.setTitle(nil, for: .normal)
        actionButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
    }

    private func addItemHandler(_ action: UIAction) {
        segueHandler?()
    }
}
