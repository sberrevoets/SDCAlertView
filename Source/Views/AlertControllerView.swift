import UIKit

protocol AlertControllerViewRepresentable {

    var title: NSAttributedString? { get set }
    var message: NSAttributedString? { get set }

    var actions: [AlertAction] { get set }
    var actionTappedHandler: (AlertAction -> Void)? { get set }

    var contentView: UIView! { get }
    var visualStyle: VisualStyle! { get set }

    var topView: UIView { get }

    var titleLabel: AlertLabel! { get }
    var messageLabel: AlertLabel! { get }
    var actionsCollectionView: ActionsCollectionView! { get }

    func enableDragTapBehavior()
    func prepareLayout()
}

extension AlertControllerViewRepresentable where Self: UIView {

    var title: NSAttributedString? {
        get { return self.titleLabel.attributedText }
        set { self.titleLabel.attributedText = newValue }
    }

    var message: NSAttributedString? {
        get { return self.messageLabel.attributedText }
        set { self.messageLabel.attributedText = newValue }
    }

    var topView: UIView { return self }

    func enableDragTapBehavior() {
        let panGesture = UIPanGestureRecognizer(target: self, action: "highlightActionForPanGesture:")
        self.addGestureRecognizer(panGesture)
    }
}

class AlertControllerView: UIView, AlertControllerViewRepresentable {

    @IBOutlet var titleLabel: AlertLabel! = AlertLabel() {
        didSet { self.titleLabel.translatesAutoresizingMaskIntoConstraints = false }
    }

    @IBOutlet var messageLabel: AlertLabel! = AlertLabel() {
        didSet { self.messageLabel.translatesAutoresizingMaskIntoConstraints = false }
    }

    @IBOutlet var actionsCollectionView: ActionsCollectionView! = ActionsCollectionView() {
        didSet { self.actionsCollectionView.translatesAutoresizingMaskIntoConstraints = false }
    }

    @IBOutlet var contentView: UIView! = UIView()

    var actions: [AlertAction] = []
    var visualStyle: VisualStyle!
    var actionTappedHandler: (AlertAction -> Void)?

    func prepareLayout() {
        self.actionsCollectionView.actions = self.actions
        self.actionsCollectionView.visualStyle = self.visualStyle
    }

    func highlightActionForPanGesture(sender: UIPanGestureRecognizer) {
        self.actionsCollectionView.highlightAction(forPanGesture: sender)
    }
}
