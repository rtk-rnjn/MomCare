import UIKit

class HalfScreenPresentationController: UIPresentationController {
    // Set the size and position of the presented view
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        // Set the height to half the screen and center it at the bottom
        let height = containerView.bounds.height / 2
        let width = containerView.bounds.width
        let yOffset = containerView.bounds.height - height
        return CGRect(x: 0, y: yOffset, width: width, height: height)
    }

    // Add a dimming background view
    private lazy var dimmingView: UIView = {
        let view = UIView(frame: containerView?.bounds ?? .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        // Add dimming view to the container
        containerView.insertSubview(dimmingView, at: 0)

        // Animate the dimming view
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        // Fade out the dimming view
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}
