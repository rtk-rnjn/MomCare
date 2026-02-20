//
//  EventKitEventView.swift
//  MomCare+
//
//  Created by Aryan singh on 15/02/26.
//

import EventKitUI
import SwiftUI

struct EventKitEventView: UIViewControllerRepresentable {
    let event: EKEvent

    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UINavigationController {
        let eventVC = EKEventViewController()
        eventVC.event = event
        eventVC.allowsEditing = true
        eventVC.delegate = context.coordinator
        return UINavigationController(rootViewController: eventVC)
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, EKEventViewDelegate {

    // MARK: Lifecycle

    init(_ parent: EventKitEventView) {
        self.parent = parent
    }

    // MARK: Internal

    var parent: EventKitEventView

    func eventViewController(_: EKEventViewController, didCompleteWith _: EKEventViewAction) {
        parent.dismiss()
    }
}
