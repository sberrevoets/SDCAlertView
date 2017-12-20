final class ActionSheetView: UIView, AlertControllerViewRepresentable {
    @IBOutlet var titleLabel: AlertLabel!
    @IBOutlet var messageLabel: AlertLabel!
    @IBOutlet var actionsCollectionView: ActionsCollectionView!
    @IBOutlet var contentView: UIView!
    @IBOutlet private var primaryView: UIView!
    @IBOutlet private var labelsContainer: UIView!
    @IBOutlet private var cancelActionView: UIView!
    @IBOutlet private var cancelLabel: UILabel!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var cancelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var titleWidthConstraint: NSLayoutConstraint!

    var actions: [AlertAction] = []

    var actionTappedHandler: ((AlertAction) -> Void)? {
        didSet { self.actionsCollectionView.actionTapped = self.actionTappedHandler }
    }

    var visualStyle: AlertVisualStyle! {
        didSet {
            let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right
            self.titleWidthConstraint.constant -= widthOffset
        }
    }

    private var cancelAction: AlertAction? {
        didSet { self.cancelLabel.attributedText = self.cancelAction?.attributedTitle }
    }

    func prepareLayout() {
        self.assignCancelAction()

        self.actionsCollectionView.actions = self.actions
        self.actionsCollectionView.visualStyle = self.visualStyle

        self.collectionViewHeightConstraint.constant = self.actionsCollectionView.displayHeight
        self.collectionViewHeightConstraint.isActive = true

        self.primaryView.layer.cornerRadius = self.visualStyle.cornerRadius
        self.primaryView.layer.masksToBounds = true
        self.cancelActionView.layer.cornerRadius = self.visualStyle.cornerRadius
        self.cancelActionView.layer.masksToBounds = true

        if let cancelAction = self.cancelAction {
            self.cancelButton.setupAccessibility(using: cancelAction)
        }

        if let backgroundColor = self.visualStyle.backgroundColor {
            self.primaryView.backgroundColor = backgroundColor
            self.cancelActionView.backgroundColor = backgroundColor
        }

        self.cancelLabel.font = self.visualStyle.font(for: self.cancelAction)
        self.cancelLabel.textColor = self.visualStyle.textColor(for: self.cancelAction) ?? self.tintColor
        self.cancelLabel.attributedText = self.cancelAction?.attributedTitle

        let cancelButtonBackground = UIImage.image(with: self.visualStyle.actionHighlightColor)
        self.cancelButton.setBackgroundImage(cancelButtonBackground, for: .highlighted)
        self.cancelHeightConstraint.constant = self.visualStyle.actionViewSize.height

        let noTextProvided = self.title?.string.isEmpty != false && self.message?.string.isEmpty != false
        let contentViewProvided = self.contentView.subviews.count > 0
        self.labelsContainer.isHidden = noTextProvided || contentViewProvided
    }

    func addDragTapBehavior() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.highlightAction(for:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc
    private func highlightAction(for sender: UIPanGestureRecognizer) {
        self.actionsCollectionView.highlightAction(for: sender)

        let cancelIsSelected = self.cancelActionView.frame.contains(sender.location(in: self))
        self.cancelButton.isHighlighted = cancelIsSelected

        if cancelIsSelected && sender.state == .ended {
            self.cancelButton.sendActions(for: .touchUpInside)
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.cancelLabel.textColor = self.visualStyle.textColor(for: self.cancelAction) ?? self.tintColor
    }

    @IBAction private func cancelTapped() {
        guard let action = self.cancelAction else {
            return
        }

        self.actionTappedHandler?(action)
    }

    private func assignCancelAction() {
        if let cancelActionIndex = self.actions.index(where: { $0.style == .preferred }) {
            self.cancelAction = self.actions[cancelActionIndex]
            self.actions.remove(at: cancelActionIndex)
        } else {
            self.cancelAction = self.actions.first
            self.actions.removeFirst()
        }
    }
}

private extension UIImage {

    class func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
