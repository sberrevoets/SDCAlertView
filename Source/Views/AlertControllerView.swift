import UIKit

protocol AlertControllerViewRepresentable {

    var title: NSAttributedString? { get set }
    var message: NSAttributedString? { get set }

    var actions: [AlertAction] { get set }
    var actionTappedHandler: ((AlertAction) -> Void)? { get set }

    var contentView: UIView! { get }
    var visualStyle: AlertVisualStyle! { get set }

    var topView: UIView { get }

    var titleLabel: AlertLabel! { get }
    var messageLabel: AlertLabel! { get }
    var actionsCollectionView: ActionsCollectionView! { get }

    func add(_ behaviors: AlertBehaviors)
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

    func add(_ behaviors: AlertBehaviors) {
        if behaviors.contains(.DragTap) {
            let panGesture = UIPanGestureRecognizer(target: self,
                action: #selector(AlertControllerView.highlightAction(for:)))
            self.addGestureRecognizer(panGesture)
        }

        if behaviors.contains(.Parallax) {
            self.addParallax()
        }
    }

    private func addParallax() {
        let parallax = self.visualStyle.parallax

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = NSNumber(value: Float(-parallax.horizontal))
        horizontal.maximumRelativeValue = NSNumber(value: Float(parallax.horizontal))

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = NSNumber(value: Float(-parallax.vertical))
        vertical.maximumRelativeValue = NSNumber(value: Float(parallax.vertical))

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]

        self.addMotionEffect(group)
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
    var visualStyle: AlertVisualStyle!
    var actionTappedHandler: ((AlertAction) -> Void)?

    func prepareLayout() {
        self.actionsCollectionView.actions = self.actions
        self.actionsCollectionView.visualStyle = self.visualStyle
    }

    func highlightAction(for sender: UIPanGestureRecognizer) {
        self.actionsCollectionView.highlightAction(for: sender)
    }
}
