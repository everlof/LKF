import UIKit

open class PresentationController: UIPresentationController {

    let dimmingView: UIView

    let backgroundAlpha: CGFloat = 0.7

    let backgroundColor = UIColor.black

    let touchBackgroundToCancel = true

    lazy var tapRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(didTapDimmingView(gesture:)))
    }()

    open override var adaptivePresentationStyle: UIModalPresentationStyle {
        return .overCurrentContext
    }

    public enum Style {
        case centered
        case bottom
    }

    public let style: Style

    public init(style: Style, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.style = style
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = backgroundColor

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        if touchBackgroundToCancel {
            dimmingView.addGestureRecognizer(tapRecognizer)
        }
    }

    @objc func didTapDimmingView(gesture: UIGestureRecognizer) {
        if gesture.state == .ended {
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    open override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        containerView?.leftAnchor.constraint(equalTo: dimmingView.leftAnchor).isActive = true
        containerView?.topAnchor.constraint(equalTo: dimmingView.topAnchor).isActive = true
        containerView?.rightAnchor.constraint(equalTo: dimmingView.rightAnchor).isActive = true
        containerView?.bottomAnchor.constraint(equalTo: dimmingView.bottomAnchor).isActive = true

        dimmingView.alpha = 0.0

        if let containerView = containerView, let toView = presentedViewController.view {
            toView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(toView)

            switch style {
            case .bottom:
                toView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
                toView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            case .centered:
                toView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                toView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                toView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85, constant: 0).isActive = true
                toView.heightAnchor.constraint(lessThanOrEqualTo: containerView.heightAnchor, multiplier: 0.8).isActive = true
            }
        }

        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = self.backgroundAlpha
            }, completion: nil)
        }
    }

    open override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0.0
            }, completion: nil)
        }
    }

    open override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }

    deinit {
        print("deinit `PresentationController`")
    }

}
