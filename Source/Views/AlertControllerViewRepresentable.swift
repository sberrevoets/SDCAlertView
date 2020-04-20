import UIKit

protocol AlertControllerViewRepresentable: UIView {
    var title: NSAttributedString? { get set }
    var message: NSAttributedString? { get set }

    var actions: [AlertAction] { get set }
    var actionTappedHandler: ((AlertAction) -> Void)? { get set }

    var topView: UIView { get }
    var contentView: UIView { get }
    var visualStyle: AlertVisualStyle! { get set }

    func add(_ behaviors: AlertBehaviors)
    func prepareLayout()
}
