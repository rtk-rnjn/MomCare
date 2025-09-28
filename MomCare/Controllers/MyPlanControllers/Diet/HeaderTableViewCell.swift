import UIKit

enum MealEditType: String {
    case addItem = "Add Item"
}

class HeaderTableViewCell: UITableViewCell {

    // MARK: Internal

    @IBOutlet var actionButton: UIButton!

    @IBOutlet var mealHeaderLabel: UILabel!
    @IBOutlet var mealHeaderButton: UIButton!

    var buttonTapHandler: (() async -> Bool)?
    var refreshHandler: (() -> Void)?
    var segueHandler: ((Any?) -> Void)?
    var allConsumed: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()

        DispatchQueue.main.async {
            self.configurePullDownMenu()
        }
    }

    func updateElements(with title: String, segueHandler: ((Any?) -> Void)?, allConsumed: Bool, buttonTapHandler: @escaping (() async -> Bool)) {
        mealHeaderLabel.text = title

        self.buttonTapHandler = buttonTapHandler
        self.segueHandler = segueHandler
        self.allConsumed = allConsumed

        let configuration = UIImage.SymbolConfiguration(scale: .medium)

        if self.allConsumed {
            mealHeaderButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)?.withTintColor(mutedRaspberryColor), for: .normal)
        } else {
            mealHeaderButton.setImage(UIImage(systemName: "circle", withConfiguration: configuration)?.withTintColor(mutedRaspberryColor), for: .normal)
        }
    }

    @IBAction func mealHeaderButtonTapped(_ sender: UIButton) {
        Task {
            let consumed = await buttonTapHandler?() ?? false
            DispatchQueue.main.async {
                self.allConsumed = consumed
                self.refreshHandler?()
            }
        }
    }

    // MARK: Private

    private var mutedRaspberryColor: UIColor {
        if let customColor: UIColor = .CustomColors.mutedRaspberry {
            return customColor
        }
        return .red
    }

    private func configurePullDownMenu() {
        let addItem = UIAction(title: "Add Item", image: UIImage(systemName: "plus"), handler: addItemHandler)
        actionButton.menu = UIMenu(title: "", children: [addItem])
        actionButton.showsMenuAsPrimaryAction = true

        actionButton.setTitle(nil, for: .normal)
        actionButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
    }

    private func addItemHandler(_ action: UIAction) {
        segueHandler?(mealHeaderLabel.text)
    }
}
