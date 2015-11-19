import UIKit

class AlertControllerView: UIView {

    var title: NSAttributedString? {
        get { return self.titleLabel.attributedText }
        set { self.titleLabel.attributedText = newValue }
    }

    var message: NSAttributedString? {
        get { return self.messageLabel.attributedText }
        set { self.messageLabel.attributedText = newValue }
    }

    var actions: [AlertAction] = []
    var actionLayout: ActionLayout = .Automatic

    var textFieldsViewController: TextFieldsViewController?

    var contentView = UIView()

    var visualStyle: VisualStyle = DefaultVisualStyle()

    private let scrollView = UIScrollView()

    private let titleLabel = AlertLabel()
    private let messageLabel = AlertLabel()
    private let actionsCollectionView = ActionsCollectionView()

    private var elements: [UIView] {
        let possibleElements: [UIView?] = [
            self.titleLabel,
            self.messageLabel,
            self.textFieldsViewController?.view,
            self.contentView.subviews.count > 0 ? self.contentView : nil,
        ]

        return possibleElements.flatMap { $0 }
    }

    private var contentHeight: CGFloat {
        guard let lastElement = self.elements.last else { return 0 }

        self.layoutIfNeeded()
        return lastElement.frame.maxY + self.visualStyle.contentPadding.bottom
    }

    func prepareLayout() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.scrollView)

        self.actionsCollectionView.actions = self.actions
        self.actionsCollectionView.visualStyle = self.visualStyle
        updateCollectionViewScrollDirection()

        createBackground()
        createUI()
        createContentConstraints()
        updateUI()
        addParallax()
    }

    func setActionTappedHandler(handler: (AlertAction) -> Void) {
        self.actionsCollectionView.actionTapped = handler
    }

    // MARK: - Private methods

    private func createUI() {
        for element in self.elements {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(element)
        }

        self.actionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.actionsCollectionView)
    }

    private func createBackground() {
        if let color = self.visualStyle.backgroundColor {
            self.backgroundColor = color
        } else {
            let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
            backgroundView.translatesAutoresizingMaskIntoConstraints = false

            self.insertSubview(backgroundView, belowSubview: self.scrollView)
            backgroundView.sdc_alignEdges(.All, withView: self)
        }
    }

    private func updateCollectionViewScrollDirection() {
        guard let layout = self.actionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
            else { return }

        if self.actionLayout == .Horizontal || (self.actions.count == 2 && self.actionLayout == .Automatic) {
            layout.scrollDirection = .Horizontal
        } else {
            layout.scrollDirection = .Vertical
        }
    }

    private func updateUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.visualStyle.cornerRadius
        self.titleLabel.font = self.visualStyle.titleLabelFont
        self.messageLabel.font = self.visualStyle.messageLabelFont
        self.textFieldsViewController?.visualStyle = self.visualStyle

        self.sdc_pinWidth(self.visualStyle.width)
        let maximumHeightOffset = -(self.visualStyle.margins.top + self.visualStyle.margins.bottom)
        self.sdc_setMaximumHeightToSuperviewHeightWithOffset(maximumHeightOffset)

        let totalHeight = self.contentHeight + self.actionsCollectionView.displayHeight
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: totalHeight)
        heightConstraint.priority = UILayoutPriorityDefaultHigh
        addConstraint(heightConstraint)
    }

    // MARK: - Constraints

    private func createContentConstraints() {
        createTitleLabelConstraints()
        createMessageLabelConstraints()
        createTextFieldsConstraints()
        createCustomContentViewConstraints()
        createCollectionViewConstraints()
        createScrollViewConstraints()
    }

    private func createTitleLabelConstraints() {
        let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right

        addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .FirstBaseline, relatedBy: .Equal,
            toItem: self, attribute: .Top, multiplier: 1, constant: self.visualStyle.contentPadding.top))
        self.titleLabel.sdc_pinWidthToWidthOfView(self, offset: -widthOffset)
        self.titleLabel.sdc_alignHorizontalCenterWithView(self)

        pinBottomOfScrollViewToView(self.titleLabel, withPriority: UILayoutPriorityDefaultLow)
    }

    private func createMessageLabelConstraints() {
        let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right

        addConstraint(NSLayoutConstraint(item: self.messageLabel, attribute: .FirstBaseline,
            relatedBy: .Equal, toItem: self.titleLabel, attribute: .Baseline , multiplier: 1,
            constant: self.visualStyle.verticalElementSpacing))
        self.messageLabel.sdc_pinWidthToWidthOfView(self, offset: -widthOffset)
        self.messageLabel.sdc_alignHorizontalCenterWithView(self)

        pinBottomOfScrollViewToView(self.messageLabel, withPriority: UILayoutPriorityDefaultLow + 1)
    }

    private func createTextFieldsConstraints() {
        guard let textFieldsView = self.textFieldsViewController?.view else { return }

        // The text fields view controller needs the visual style to calculate its height
        self.textFieldsViewController?.visualStyle = self.visualStyle

        let height = self.textFieldsViewController?.requiredHeight
        let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right

        addConstraint(NSLayoutConstraint(item: textFieldsView, attribute: .Top, relatedBy: .Equal,
            toItem: self.messageLabel, attribute: .Baseline, multiplier: 1,
            constant: self.visualStyle.verticalElementSpacing))

        textFieldsView.sdc_pinWidthToWidthOfView(self, offset: -widthOffset)
        textFieldsView.sdc_alignHorizontalCenterWithView(self)
        textFieldsView.sdc_pinHeight(height!)

        pinBottomOfScrollViewToView(textFieldsView, withPriority: UILayoutPriorityDefaultLow + 2)
    }

    private func createCustomContentViewConstraints() {
        if !self.elements.contains(self.contentView) { return }

        let aligningView = self.textFieldsViewController?.view ?? self.messageLabel
        let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right

        let topSpacing = self.visualStyle.verticalElementSpacing
        self.contentView.sdc_alignEdge(.Top, withEdge: .Bottom, ofView: aligningView, inset: topSpacing)
        self.contentView.sdc_alignHorizontalCenterWithView(self)
        self.contentView.sdc_pinWidthToWidthOfView(self, offset: -widthOffset)
        self.contentView.sdc_alignHorizontalCenterWithView(self)

        pinBottomOfScrollViewToView(self.contentView, withPriority: UILayoutPriorityDefaultLow + 3)
    }

    private func createCollectionViewConstraints() {
        let actionsHeight = self.actionsCollectionView.displayHeight
        self.actionsCollectionView.sdc_pinHeight(actionsHeight)
        self.actionsCollectionView.sdc_pinWidthToWidthOfView(self)
        self.actionsCollectionView.sdc_alignEdge(.Top, withEdge: .Bottom, ofView: self.scrollView)
        self.actionsCollectionView.sdc_alignHorizontalCenterWithView(self)
        self.actionsCollectionView.sdc_alignEdges(.Bottom, withView: self)
    }

    private func createScrollViewConstraints() {
        self.scrollView.sdc_alignEdges([.Left, .Right, .Top], withView: self)
    }

    private func pinBottomOfScrollViewToView(view: UIView, withPriority priority: UILayoutPriority) {
        let bottomAnchor = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal,
            toItem: self.scrollView, attribute: .Bottom, multiplier: 1,
            constant: -self.visualStyle.contentPadding.bottom)
        bottomAnchor.priority = priority
        addConstraint(bottomAnchor)
    }

    private func addParallax() {
        let parallax = self.visualStyle.parallax

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = NSNumber(float: Float(-parallax.horizontal))
        horizontal.maximumRelativeValue = NSNumber(float: Float(parallax.horizontal))

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        vertical.minimumRelativeValue = NSNumber(float: Float(-parallax.vertical))
        vertical.maximumRelativeValue = NSNumber(float: Float(parallax.vertical))

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]

        self.addMotionEffect(group)
    }
}
