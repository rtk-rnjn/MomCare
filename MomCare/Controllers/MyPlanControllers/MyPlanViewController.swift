import UIKit

enum MyPlanViewControlSegmentValue: Int {
    case dietContainerView = 0
    case exerciseContainerView = 1
}

class MyPlanViewController: UIViewController {

    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBOutlet var dietContainerView: UIView!
    @IBOutlet var exerciseContainerView: UIView!

    private var currentSegmentValue = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
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

    func updateView() {
        currentSegmentValue = segmentedControl.selectedSegmentIndex
        let segmentControlView = MyPlanViewControlSegmentValue(rawValue: currentSegmentValue)

        hideAllViews(except: segmentControlView)
    }
}
