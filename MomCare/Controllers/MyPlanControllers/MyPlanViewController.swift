import UIKit
import SwiftUI

enum MyPlanViewControlSegmentValue: Int {
    case dietContainerView = 0
    case exerciseContainerView = 1
}

class MyPlanViewController: UIViewController {

    // MARK: Internal

    @IBOutlet var myPlanSegmentedControl: UISegmentedControl!

    @IBOutlet var dietContainerView: UIView!
    @IBOutlet var exerciseContainerView: UIView!

    var currentSegmentValue = 0

    var exercisesLoaded: Bool = false
    var dietsLoaded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView(with: currentSegmentValue)
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        setupBasicAccessibility(title: "My Plan")
        
        // Configure segmented control
        setupSegmentedControlAccessibility(control: myPlanSegmentedControl, label: "Plan type selector")
        
        // Set individual segment labels
        myPlanSegmentedControl.setTitle("Diet Plan", forSegmentAt: 0)
        myPlanSegmentedControl.setTitle("Exercise Plan", forSegmentAt: 1)
        
        // Configure container views
        dietContainerView.accessibilityLabel = "Diet plan content"
        dietContainerView.accessibilityTraits = [.none]
        
        exerciseContainerView.accessibilityLabel = "Exercise plan content"
        exerciseContainerView.accessibilityTraits = [.none]
        
        // Add accessibility hints
        myPlanSegmentedControl.accessibilityHint = "Switch between diet and exercise plans"
        
        // Announce initial state
        announceAccessibilityUpdate("My Plan screen loaded. Currently showing \(currentSegmentValue == 0 ? "diet" : "exercise") plan.")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dietContainerView.backgroundColor = .white
        exerciseContainerView.layer.cornerRadius = 16

        prepareSegmentedControl()
        updateView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "embedShowDietViewController":
            if let dietViewController = segue.destination as? DietViewController {
                dietViewController.myPlanViewController = self
            }

        default:
            break
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateView()
        
        // Announce segment change to VoiceOver users
        let selectedTitle = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "plan"
        announceAccessibilityUpdate("Switched to \(selectedTitle)")
    }

    func prepareSegmentedControl() {
        myPlanSegmentedControl.selectedSegmentIndex = currentSegmentValue

        let normalTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]

        let selectedBackground = UIColor(hex: "924350")

        let selectedTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedBackground
        ]

        myPlanSegmentedControl.setTitleTextAttributes(normalTextAttribute, for: .normal)
        myPlanSegmentedControl.setTitleTextAttributes(selectedTextAttribute, for: .selected)
    }

    func updateView() {
        updateMainView(with: nil)
    }

    func updateView(with index: Int) {
        updateMainView(with: index)
    }

    // MARK: Private

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
            fatalError("love is beautiful thing")
        }
    }

}
