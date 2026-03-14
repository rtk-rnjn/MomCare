import EventKitUI
import SwiftUI

struct EKEventView: UIViewControllerRepresentable {
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

    init(_ parent: EKEventView) {
        self.parent = parent
    }

    // MARK: Internal

    var parent: EKEventView

    func eventViewController(_: EKEventViewController, didCompleteWith _: EKEventViewAction) {
        parent.dismiss()
    }
}
