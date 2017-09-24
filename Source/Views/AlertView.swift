final class AlertView: UIView, AlertControllerViewRepresentable {

    var titleLabel: AlertLabel! = AlertLabel()
    var messageLabel: AlertLabel! = AlertLabel()
    var actionsCollectionView: ActionsCollectionView! = ActionsCollectionView()
    var contentView: UIView! = UIView()
    var actions: [AlertAction] = []
    var actionLayout = ActionLayout.automatic

    var textFieldsViewController: TextFieldsViewController? {
        didSet { self.textFieldsViewController?.visualStyle = self.visualStyle }
    }

    var visualStyle: AlertVisualStyle! {
        didSet { self.textFieldsViewController?.visualStyle = self.visualStyle }
    }

    var actionTappedHandler: ((AlertAction) -> Void)? {
        get { return self.actionsCollectionView.actionTapped }
        set { self.actionsCollectionView.actionTapped = newValue }
    }

    var topView: UIView {
        return self.scrollView
    }

    private let scrollView = UIScrollView()

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
        guard let lastElement = self.elements.last else {
            return 0
        }

        lastElement.layoutIfNeeded()
        return lastElement.frame.maxY + self.visualStyle.contentPadding.bottom
    }

    convenience init() {
        self.init(frame: .zero)
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.messageLabel.font = UIFont.systemFont(ofSize: 13)
    }

    func prepareLayout() {
        self.actionsCollectionView.actions = self.actions
        self.actionsCollectionView.visualStyle = self.visualStyle

        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.scrollView)

        self.updateCollectionViewScrollDirection()

        self.createBackground()
        self.createUI()
        self.createContentConstraints()
        self.updateUI()
    }

    func addDragTapBehavior() {
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(self.highlightAction(for:)))
        self.addGestureRecognizer(panGesture)
    }

    // MARK: - Private methods

    private func createBackground() {
        if let color = self.visualStyle.backgroundColor {
            self.backgroundColor = color
        } else {
            let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            backgroundView.translatesAutoresizingMaskIntoConstraints = false

            self.insertSubview(backgroundView, belowSubview: self.scrollView)
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    }

    private func createUI() {
        for element in self.elements {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(element)
        }

        self.actionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.actionsCollectionView)
    }

    private func updateCollectionViewScrollDirection() {
        let layout = self.actionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout

        if self.actionLayout == .horizontal || (self.actions.count == 2 && self.actionLayout == .automatic) {
            layout?.scrollDirection = .horizontal
        } else {
            layout?.scrollDirection = .vertical
        }
    }

    private func updateUI() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.visualStyle.cornerRadius
        self.textFieldsViewController?.visualStyle = self.visualStyle
    }

    override var intrinsicContentSize: CGSize {
        let totalHeight = self.contentHeight + self.actionsCollectionView.displayHeight
        return CGSize(width: UIViewNoIntrinsicMetric, height: totalHeight)
    }

    @objc
    private func highlightAction(for sender: UIPanGestureRecognizer) {
        self.actionsCollectionView.highlightAction(for: sender)
    }

    // MARK: - Constraints

    private func createContentConstraints() {
        self.createTitleLabelConstraints()
        self.createMessageLabelConstraints()
        self.createTextFieldsConstraints()
        self.createCustomContentViewConstraints()
        self.createCollectionViewConstraints()
        self.createScrollViewConstraints()
    }

    private func createTitleLabelConstraints() {
        let contentPadding = self.visualStyle.contentPadding
        let insets = UIEdgeInsets(top: 0, left: contentPadding.left, bottom: 0, right: -contentPadding.right)

        NSLayoutConstraint.activate([
            self.titleLabel.firstBaselineAnchor.constraint(equalTo: self.topAnchor,
                                                           constant: contentPadding.top),
            self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: insets.left),
            self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: insets.right),
        ])

        self.pinBottomOfScrollView(to: self.messageLabel, withPriority: .defaultLow)

    }

    private func createMessageLabelConstraints() {
        let contentPadding = self.visualStyle.contentPadding
        NSLayoutConstraint.activate([
            self.messageLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: contentPadding.left),
            self.messageLabel.rightAnchor.constraint(equalTo: self.rightAnchor,
                                        constant: -contentPadding.right),
            self.messageLabel.firstBaselineAnchor.constraint(equalTo: self.titleLabel.lastBaselineAnchor,
                                                            constant: self.visualStyle.verticalElementSpacing)
        ])

        self.pinBottomOfScrollView(to: self.messageLabel, withPriority: .defaultLow + 1.0)
    }

    private func createTextFieldsConstraints() {
        self.textFieldsViewController?.visualStyle = self.visualStyle

        guard let textFieldsView = self.textFieldsViewController?.view,
              let height = self.textFieldsViewController?.requiredHeight else
        {
            return
        }

        let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right

        NSLayoutConstraint.activate([
            textFieldsView.topAnchor.constraint(equalTo: self.messageLabel.lastBaselineAnchor,
                                                constant: self.visualStyle.verticalElementSpacing),
            textFieldsView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -widthOffset),
            textFieldsView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textFieldsView.heightAnchor.constraint(equalToConstant: height),
        ])

        self.pinBottomOfScrollView(to: textFieldsView, withPriority: .defaultLow + 2.0)
    }

    private func createCustomContentViewConstraints() {
        if !self.elements.contains(self.contentView) {
            return
        }

        let aligningView = self.textFieldsViewController?.view ?? self.messageLabel!
        let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right

        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: aligningView.bottomAnchor,
                                                  constant: self.visualStyle.verticalElementSpacing),
            self.contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -widthOffset),
        ])

        self.pinBottomOfScrollView(to: self.contentView, withPriority: .defaultLow + 3.0)
    }

    private func createCollectionViewConstraints() {
        let height = self.actionsCollectionView.displayHeight
        let heightConstraint = self.actionsCollectionView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            heightConstraint,
            self.actionsCollectionView.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.actionsCollectionView.topAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.actionsCollectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.actionsCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    private func createScrollViewConstraints() {
        self.scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.scrollView.layoutIfNeeded()

        let height = self.scrollView.contentSize.height
        let heightConstraint = self.scrollView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

    }

    private func pinBottomOfScrollView(to view: UIView, withPriority priority: UILayoutPriority) {
        let bottom = view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
        bottom.constant = -self.visualStyle.contentPadding.bottom
        bottom.priority = priority
        bottom.isActive = true
    }
}

private extension UILayoutPriority {
    static func + (lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(rawValue: lhs.rawValue + rhs)
    }
}
