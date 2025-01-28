import UIKit

enum MyPlanViewControlSegmentValue: Int {
    case dietContainerView = 0
    case exerciseContainerView = 1
}

class MyPlanViewController: UIViewController {

    @IBOutlet var myPlanSegmentedControl: UISegmentedControl!

    @IBOutlet var dietContainerView: UIView!
    @IBOutlet var exerciseContainerView: UIView!

    var currentSegmentValue = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView(with: currentSegmentValue)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dietContainerView.backgroundColor = .white
        exerciseContainerView.layer.cornerRadius = 15

        prepareSegmentedControl()
        updateView()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateView()
    }

    func prepareSegmentedControl() {
        myPlanSegmentedControl.selectedSegmentIndex = currentSegmentValue

        let normalTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]

        let selectedBackground = Converters.convertHexToUIColor(hex: "924350")

        let selectedTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedBackground
        ]

        myPlanSegmentedControl.setTitleTextAttributes(normalTextAttribute, for: .normal)
        myPlanSegmentedControl.setTitleTextAttributes(selectedTextAttribute, for: .selected)
    }

    private func hideAllViews(except view: MyPlanViewControlSegmentValue?) {
        switch view {
        case .dietContainerView:
            exerciseContainerView.isHidden = true
            dietContainerView.isHidden = false
        case .exerciseContainerView:
            exerciseContainerView.isHidden = false
            dietContainerView.isHidden = true
        default:
            fatalError("someone said, love is boring")
        }
    }

    private func updateMainView(with index: Int?) {
        if index != nil {
            currentSegmentValue = index!
            myPlanSegmentedControl.selectedSegmentIndex = index!
            myPlanSegmentedControl.sendActions(for: .valueChanged)
        } else {
            currentSegmentValue = myPlanSegmentedControl.selectedSegmentIndex
        }

        switch currentSegmentValue {
        case 0:
            hideAllViews(except: .dietContainerView)
        case 1:
            hideAllViews(except: .exerciseContainerView)
        default:
            // Should never happen
            fatalError("love is beautiful thing")
        }
    }

    func updateView() {
        updateMainView(with: nil)
    }

    func updateView(with index: Int) {
        updateMainView(with: index)
    }

}
