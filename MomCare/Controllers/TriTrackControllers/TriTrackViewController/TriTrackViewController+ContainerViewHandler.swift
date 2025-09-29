//
//  TriTrackViewController+ContainerViewHandler.swift
//  MomCare
//
//  Created by Ritik Ranjan on 24/01/25.
//

import UIKit

extension TriTrackViewController {
    func prepareSegmentedControl() {
        triTrackSegmentedControl.selectedSegmentIndex = currentSegmentValue

        let normalTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]

        let selectedBackground: UIColor? = .CustomColors.mutedRaspberry

        let selectedTextAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedBackground ?? .red
        ]

        triTrackSegmentedControl.setTitleTextAttributes(normalTextAttribute, for: .normal)
        triTrackSegmentedControl.setTitleTextAttributes(selectedTextAttribute, for: .selected)
    }

    private func hideAllContainers(except: TriTrackContainerViewType) {
        let allContainers: [TriTrackContainerViewType: UIView] = [
            .meAndBabyContainerView: meAndBabyContainerView,
            .eventsContainerView: eventsContainerView,
            .symptomsContainerView: symptomsContainerView
        ]

        allContainers.values.forEach { $0.isHidden = true }

        if let container = allContainers[except] {
            container.isHidden = false
        }
    }

    func updateView(with index: Int? = nil) {
        if let index {
            currentSegmentValue = index
            triTrackSegmentedControl.selectedSegmentIndex = index
            triTrackSegmentedControl.sendActions(for: .valueChanged)
        } else {
            currentSegmentValue = triTrackSegmentedControl.selectedSegmentIndex
        }

        switch currentSegmentValue {
        case 0:
            addButton.isHidden = true
            refreshButton.isHidden = true
            hideAllContainers(except: .meAndBabyContainerView)

        case 1:
            addButton.isHidden = false
            refreshButton.isHidden = false
            hideAllContainers(except: .eventsContainerView)

        case 2:
            addButton.isHidden = false
            refreshButton.isHidden = false
            hideAllContainers(except: .symptomsContainerView)

        default:
            // Should never happen
            fatalError("love is beautiful thing")
        }
    }
}
