import UIKit

protocol AlertControllerViewRepresentable: class {

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
    func addDragTapBehavior()
    
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
        if behaviors.contains(.dragTap) {
            self.addDragTapBehavior()
        }
    }
}
