//

//  TriTrackViewController.swift

//  MomCare

//

//  Created by Ritik Ranjan on 16/01/25.

//

import UIKit

enum ContainerType {

    case meAndBaby

    case events

    case symptoms

}

class TriTrackViewController: UIViewController {

    @IBOutlet var triTrackInternalView: UIView!

    @IBOutlet var addButton: UIBarButtonItem!

    @IBOutlet var triTrackSegmentedControl: UISegmentedControl!

    @IBOutlet var meAndBabyContainerView: UIView!

    @IBOutlet var eventsContainerView: UIView!

    @IBOutlet var symptomsContainerView: UIView!

    var currentSegmentIndex: Int = 0

    override func viewDidLoad() {

        super.viewDidLoad()

        triTrackInternalView.backgroundColor = .white

        triTrackInternalView.layer.cornerRadius = 15

        prepareSegmentedControl()

        updateView()

    }

    func hideAllContainers(except: ContainerType) {

        let allContainers: [ContainerType: UIView] = [

            .meAndBaby: meAndBabyContainerView, .events: eventsContainerView, .symptoms: symptomsContainerView

        ]

        allContainers.values.forEach { $0.isHidden = true }

        if let container = allContainers[except] {

            container.isHidden = false

        }

    }

    func prepareSegmentedControl() {

        triTrackSegmentedControl.selectedSegmentIndex = currentSegmentIndex

        let normalTextAttribute: [NSAttributedString.Key: Any] = [

            .foregroundColor: UIColor.white

        ]

        /* https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values */

        let rgbValue: UInt64 = 0

        // Hex: 924350

        let red = CGFloat((rgbValue & 0x920000) >> 16) / 255.0

        let green = CGFloat((rgbValue & 0x004300) >> 8) / 255.0

        let blue = CGFloat(rgbValue & 0x000050) / 255.0

        let selectedBackground = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

        let selectedTextAttribute: [NSAttributedString.Key: Any] = [

            .foregroundColor: selectedBackground

        ]

        triTrackSegmentedControl.setTitleTextAttributes(normalTextAttribute, for: .normal)

        triTrackSegmentedControl.setTitleTextAttributes(selectedTextAttribute, for: .selected)

    }

    func updateView() {

        currentSegmentIndex = triTrackSegmentedControl.selectedSegmentIndex

        switch currentSegmentIndex {

        case 0: 

            addButton.isEnabled = false

            hideAllContainers(except: .meAndBaby)

        case 1: 

            addButton.isEnabled = true

            hideAllContainers(except: .events)

        case 2: 

            addButton.isEnabled = true

            hideAllContainers(except: .symptoms)

        default: 

            // Should never happen

            fatalError()

        }

    }

    @IBAction func segmentTapped(_ sender: UISegmentedControl) {

        updateView()

    }

    @IBAction func unwinToTriTrack(_ sender: UIStoryboardSegue) {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Image using ChatGPT in production Code. sorry guys

        if segue.identifier == "segueTriTrack" {

            if let destinationVC = segue.destination as? UINavigationController {

                let destinationVCTopController = destinationVC.topViewController as! TriTrackAddEventViewController

                destinationVCTopController.viewControllerValue = TriTrackViewControlSegmentValue(rawValue: triTrackSegmentedControl.selectedSegmentIndex)

            }

        }

    }

}
