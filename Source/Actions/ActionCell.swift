import UIKit

final class ActionCell: UICollectionViewCell {

    @IBOutlet private(set) var stackView: UIStackView!
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private var highlightedBackgroundView: UIView!

    private var action: AlertAction?
    private var textColor: UIColor?

    var isEnabled = true {
        didSet { self.titleLabel.isEnabled = self.isEnabled }
    }

    override var isHighlighted: Bool {
        didSet { self.highlightedBackgroundView.isHidden = !self.isHighlighted }
    }

    func set(_ action: AlertAction, with visualStyle: AlertVisualStyle) {
        self.action = action
        action.actionView = self

        self.titleLabel.font = visualStyle.font(for: action)
        
        self.textColor = visualStyle.textColor(for: action)
        self.titleLabel.textColor = self.textColor ?? self.tintColor
        
        self.titleLabel.attributedText = action.attributedTitle

        self.highlightedBackgroundView.backgroundColor = visualStyle.actionHighlightColor

        if let imageView = action.imageView {
            stackView.insertArrangedSubview(imageView, at: 0)
        }
        if let accessoryView = action.accessoryView {
            stackView.addArrangedSubview(accessoryView)
        }
        titleLabel.textAlignment = visualStyle.textAlignment(for: action)
        self.setupAccessibility(using: action)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.titleLabel.textColor = self.textColor ?? self.tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = action?.imageView {
            constrainSecondaryView(imageView)
        }
        if let accessoryView = action?.accessoryView {
            constrainSecondaryView(accessoryView)
        }
    }
    
    private func constrainSecondaryView(_ view: UIView) {
        var size = view.intrinsicContentSize
        if size.height == UIView.noIntrinsicMetric || size.width == UIView.noIntrinsicMetric {
            size = CGSize(width: stackView.bounds.height, height: stackView.bounds.height)
        }
        if size.height > stackView.bounds.height {
            // if size doesn't fit, scale proportionally
            size.width /= size.height / stackView.bounds.height
            size.height = stackView.bounds.height
        }
        NSLayoutConstraint.deactivate(view.constraints)
        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        view.setContentHuggingPriority(UILayoutPriority(rawValue: 800), for: .horizontal) // must be higher than 760 for UIStackView to accept it. Ensures to maximize space for titleLabel.
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
