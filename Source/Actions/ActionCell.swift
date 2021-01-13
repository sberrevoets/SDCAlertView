import UIKit

@objc(SDCActionCell)
final class ActionCell: UICollectionViewCell {
    @IBOutlet private(set) var stackView: UIStackView!
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private var highlightedBackgroundView: UIView!

    private var textColor: UIColor?

    var isEnabled = true {
        didSet { self.titleLabel.isEnabled = self.isEnabled }
    }

    override var isHighlighted: Bool {
        didSet { self.highlightedBackgroundView.isHidden = !self.isHighlighted }
    }

    func set(_ action: AlertAction, with visualStyle: AlertVisualStyle) {
        action.actionView = self

        self.textColor = visualStyle.textColor(for: action)
        self.titleLabel.font = visualStyle.font(for: action)
        self.titleLabel.textColor = self.textColor ?? self.tintColor
        self.titleLabel.attributedText = action.attributedTitle
        self.titleLabel.textAlignment =
            action.imageView.image != nil || action.accessoryView != nil ? .left : .center

        self.highlightedBackgroundView.backgroundColor = visualStyle.actionHighlightColor

        if action.imageView.image != nil {
            self.stackView.insertArrangedSubview(action.imageView, at: 0)
            self.constrainSecondaryView(action.imageView)
        }

        if let accessoryView = action.accessoryView {
            self.stackView.addArrangedSubview(accessoryView)
            self.constrainSecondaryView(accessoryView)
        }

        self.setupAccessibility(using: action)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.titleLabel.textColor = self.textColor ?? self.tintColor
    }

    private func constrainSecondaryView(_ view: UIView) {
        let height = view.heightAnchor.constraint(lessThanOrEqualTo: self.stackView.heightAnchor)
        height.priority = .required
        height.isActive = true

        let aspectRatio = view.intrinsicContentSize.height / view.intrinsicContentSize.width
        let ratioConstraint = view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: aspectRatio)

        // Allow custom width constraints to override the aspect ratio preservation
        ratioConstraint.priority = .required - 1
        ratioConstraint.isActive = true

        view.setContentHuggingPriority(UILayoutPriority(rawValue: 800), for: .horizontal)
    }
}

final class ActionSeparatorView: UICollectionReusableView {

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let attributes = layoutAttributes as? ActionsCollectionViewLayoutAttributes {
            self.backgroundColor = attributes.backgroundColor
        }
    }
}
