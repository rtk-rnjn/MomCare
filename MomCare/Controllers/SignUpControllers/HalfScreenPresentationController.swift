import UIKit

class HalfScreenPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }

        let height = containerView.bounds.height / 2
        let width = containerView.bounds.width
        let yOffset = containerView.bounds.height - height
        return CGRect(x: 0, y: yOffset, width: width, height: height)
    }

    private lazy var dimmingView: UIView = {
        let view = UIView(frame: containerView?.bounds ?? .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        containerView.insertSubview(dimmingView, at: 0)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}
