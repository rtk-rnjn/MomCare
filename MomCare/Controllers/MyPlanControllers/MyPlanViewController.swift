import UIKit

enum MyPlanViewControlSegmentValue: Int {
    case dietContainerView = 0
    case exerciseContainerView = 1
}

class MyPlanViewController: UIViewController {

    @IBOutlet var myPlanSegmentedControl: UISegmentedControl!

    @IBOutlet var dietContainerView: UIView!
    @IBOutlet var exerciseContainerView: UIView!

    private var currentSegmentValue = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        prepareSegmentedControl()
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

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateView()
    }

    private func updateView() {
        currentSegmentValue = myPlanSegmentedControl.selectedSegmentIndex
        let segmentControlView = MyPlanViewControlSegmentValue(rawValue: currentSegmentValue)

        hideAllViews(except: segmentControlView)
    }

    private func prepareSegmentedControl() {
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
}
