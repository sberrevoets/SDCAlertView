import UIKit

final class ActionSheetView: UIView, AlertControllerViewRepresentable {
    @IBOutlet var titleLabel: AlertLabel!
    @IBOutlet var messageLabel: AlertLabel!
    @IBOutlet var actionsCollectionView: ActionsCollectionView!
    @IBOutlet var contentView: UIView!
    @IBOutlet private var primaryView: UIView!
    @IBOutlet private var primaryBlurView: UIVisualEffectView!
    @IBOutlet private var primaryVibrancyView: UIVisualEffectView!
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
        self.prepareCollectionView()
        self.createCornerRadius()
        self.setUpCancelButton()
        self.setUpContentView()

        if let backgroundColor = self.visualStyle.backgroundColor {
            self.labelsContainer.backgroundColor = backgroundColor
            self.primaryView.backgroundColor = backgroundColor
            self.cancelActionView.backgroundColor = backgroundColor
        }
        
        if #available(iOS 13.0, *) {
            let blurEffect = UIBlurEffect(style: .systemMaterial)
            self.primaryBlurView.effect = blurEffect
            self.primaryVibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: .secondaryLabel)
        }
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
            self.cancelButton.sendActions(for: UIControl.Event.touchUpInside)
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

    // MARK: - Private

    private func assignCancelAction() {
        if let cancelActionIndex = self.actions.firstIndex(where: { $0.style == .preferred }) {
            self.cancelAction = self.actions[cancelActionIndex]
            self.actions.remove(at: cancelActionIndex)
        } else {
            self.cancelAction = self.actions.first
            self.actions.removeFirst()
        }
    }

    private func prepareCollectionView() {
        self.actionsCollectionView.actions = self.actions
        self.actionsCollectionView.visualStyle = self.visualStyle

        self.collectionViewHeightConstraint.constant = self.actionsCollectionView.displayHeight
        self.collectionViewHeightConstraint.isActive = true
    }

    private func createCornerRadius() {
        self.primaryView.layer.cornerRadius = self.visualStyle.cornerRadius
        self.primaryView.layer.masksToBounds = true
        self.cancelActionView.layer.cornerRadius = self.visualStyle.cornerRadius
        self.cancelActionView.layer.masksToBounds = true
    }

    private func setUpCancelButton() {
        if let cancelAction = self.cancelAction {
            self.cancelButton.setupAccessibility(using: cancelAction)
        }

        self.cancelLabel.font = self.visualStyle.font(for: self.cancelAction)
        self.cancelLabel.textColor = self.visualStyle.textColor(for: self.cancelAction) ?? self.tintColor
        self.cancelLabel.attributedText = self.cancelAction?.attributedTitle

        let cancelButtonBackground = UIImage.image(with: self.visualStyle.actionHighlightColor)
        self.cancelButton.setBackgroundImage(cancelButtonBackground, for: .highlighted)
        self.cancelHeightConstraint.constant = self.visualStyle.actionViewSize.height

        if let cancelBackgroundColor = self.visualStyle.actionViewCancelBackgroundColor {
            self.cancelButton.backgroundColor = cancelBackgroundColor
        }
    }

    private func setUpContentView() {
        let textProvided = self.title?.string.isEmpty == false || self.message?.string.isEmpty == false
        let contentViewProvided = self.contentView.subviews.count > 0

        if self.message == nil {
            self.messageLabel.removeFromSuperview()
        }

        self.primaryVibrancyView.superview?.isHidden = !textProvided
        self.contentView.superview?.isHidden = !contentViewProvided
        if contentViewProvided, let contentSuperview = self.contentView.superview {
            let verticalSpacing = self.visualStyle.verticalElementSpacing
            let topSpace = (textProvided ? -0.5 * verticalSpacing : 0) + verticalSpacing
            NSLayoutConstraint.activate([
                self.contentView.topAnchor.constraint(equalTo: contentSuperview.topAnchor,
                                                      constant: topSpace),
                contentSuperview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                                         constant: self.visualStyle.contentPadding.bottom)
            ])
        }
    }
}

private extension UIImage {
    static func image(with color: UIColor) -> UIImage? {
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        color.setFill()
        context.fill(rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
