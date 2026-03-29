import EventKitUI
import SwiftUI

struct EKEventView: UIViewControllerRepresentable {
    let event: EKEvent

    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UINavigationController {
        let eventViewController = EKEventViewController()
        eventViewController.event = event
        eventViewController.allowsEditing = true
        eventViewController.delegate = context.coordinator
        return UINavigationController(rootViewController: eventViewController)
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

@MainActor
class Coordinator: NSObject, EKEventViewDelegate {
    // MARK: Lifecycle

    init(_ parent: EKEventView) {
        self.parent = parent
    }

    // MARK: Internal

    var parent: EKEventView

    func eventViewController(_: EKEventViewController, didCompleteWith _: EKEventViewAction) {
        parent.dismiss()
    }
}
