import UIKit

class ExtensionPresentationController: UIPresentationController {

    // MARK: - Private Properties

    fileprivate var direction: Direction

    fileprivate let dimmingView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Appearance.dimmingViewBGColor
        $0.alpha = Constants.zeroAlpha
        return $0
    }(UIView())

    // MARK: - Initializers

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: Direction) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        self.registerKeyboardObservers()
    }

    deinit {
        removeKeyboardObservers()
    }

    // MARK: - Presentation Controller Overrides

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        frame.origin.x = (containerView!.frame.width - frame.width) / 2.0
        frame.origin.y = (containerView!.frame.height - frame.height) / 2.0
        return frame
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: (parentSize.width * Appearance.widthRatio), height: (parentSize.height * Appearance.heightRatio))
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = Appearance.cornerRadius
        presentedView?.clipsToBounds = true
    }

    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = Constants.fullAlpha
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = Constants.fullAlpha
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = Constants.zeroAlpha
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = Constants.zeroAlpha
        })
    }
}

// MARK: - Keyboard Handling

private extension ExtensionPresentationController {
    func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown(notification: Notification) {
        let keyboardFrame = notification.keyboardEndFrame() ?? .zero
        let duration = notification.keyboardAnimationDuration() ?? Constants.defaultAnimationDuration
        animateForWithKeyboardFrame(presentedView!.convert(keyboardFrame, from: nil), duration: duration)
    }

    @objc func keyboardWillHide (notification: Notification) {
        let keyboardFrame = notification.keyboardEndFrame() ?? .zero
        let duration = notification.keyboardAnimationDuration() ?? Constants.defaultAnimationDuration
        animateForWithKeyboardFrame(presentedView!.convert(keyboardFrame, from: nil), duration: duration)
    }

    func getTranslationFrame(keyboardFrame: CGRect, presentedFrame: CGRect) -> CGRect {
        let keyboardTop = UIScreen.main.bounds.height - (keyboardFrame.size.height + Constants.bottomKeyboardMargin)
        let presentedViewBottom = presentedFrame.origin.y + presentedFrame.height
        let offset = presentedViewBottom - keyboardTop

        guard offset > 0.0  else {
            return presentedFrame
        }

        let newHeight = presentedFrame.size.height - offset
        let frame = CGRect(x: presentedFrame.origin.x, y: presentedFrame.origin.y, width: presentedFrame.size.width, height: newHeight)
        return frame
    }

    func animateForWithKeyboardFrame(_ keyboardFrame: CGRect, duration: Double) {
        let presentedFrame = frameOfPresentedViewInContainerView
        let translatedFrame = getTranslationFrame(keyboardFrame: keyboardFrame, presentedFrame: presentedFrame)
        if translatedFrame != presentedFrame {
            UIView.animate(withDuration: duration, animations: {
                self.presentedView?.frame = translatedFrame
            })
        }
    }
}

// MARK: - Constants

private extension ExtensionPresentationController {
    struct Constants {
        static let fullAlpha: CGFloat = 1.0
        static let zeroAlpha: CGFloat = 0.0
        static let defaultAnimationDuration: Double = 0.33
        static let bottomKeyboardMargin: CGFloat = 10.0
    }
    
    struct Appearance {
        static let dimmingViewBGColor = UIColor(white: 0.0, alpha: 0.5)
        static let cornerRadius: CGFloat = 13.0
        static let widthRatio: CGFloat = 0.97
        static let heightRatio: CGFloat = 0.92
    }
}

// MARK: Notification + UIKeyboardInfo

private extension Notification {

    /// Gets the optional CGRect value of the UIKeyboardFrameEndUserInfoKey from a UIKeyboard notification
    func keyboardEndFrame () -> CGRect? {
        return (self.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    /// Gets the optional AnimationDuration value of the UIKeyboardAnimationDurationUserInfoKey from a UIKeyboard notification
    func keyboardAnimationDuration () -> Double? {
        return (self.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
}
