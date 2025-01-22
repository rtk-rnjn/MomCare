import UIKit

class MyPlanViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!

    private var currentViewController: UIViewController?

    override func viewDidLoad() {

        super.viewDidLoad()

        switchToViewController(identifier: "DietVC")

        let unselectedAttributes: [NSAttributedString.Key: Any] = [

                .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14, weight: .regular)]

        let selectedAttributes: [NSAttributedString.Key: Any] = [

            .foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 14, weight: .bold)

            ]

        segmentedControl.setTitleTextAttributes(unselectedAttributes, for: .normal)

        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)

    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {

        if sender.selectedSegmentIndex == 0 {

            switchToViewController(identifier: "DietVC")

        } else {

            switchToViewController(identifier: "ExerciseVC")

        }

    }

    private func switchToViewController(identifier: String) {

        // Remove the current child view controller

        if let currentVC = currentViewController {

            currentVC.willMove(toParent: nil)

            currentVC.view.removeFromSuperview()

            currentVC.removeFromParent()

        }

        // Instantiate the new child view controller

        let storyboard = UIStoryboard(name: "MyPlan", bundle: nil)

        let newViewController = storyboard.instantiateViewController(withIdentifier: identifier)

        // Add the new child view controller

        addChild(newViewController)

        newViewController.view.frame = containerView.bounds

        containerView.addSubview(newViewController.view)

        newViewController.didMove(toParent: self)

        currentViewController = newViewController

    }

}
