import UIKit

final class ActionCell: UICollectionViewCell {

    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private var highlightedBackgroundView: UIView!

    private var titleLabelColorFromVisualStyle:UIColor?
    
    var enabled = true {
        didSet { self.titleLabel.enabled = self.enabled }
    }

    override var highlighted: Bool {
        didSet { self.highlightedBackgroundView.hidden = !self.highlighted }
    }

    func setAction(action: AlertAction, withVisualStyle visualStyle: VisualStyle) {
        action.actionView = self

        self.titleLabel.font = visualStyle.font(forAction: action)
        
        titleLabelColorFromVisualStyle = visualStyle.textColor(forAction: action)
        self.titleLabel.textColor = titleLabelColorFromVisualStyle ?? self.tintColor
        
        self.titleLabel.attributedText = action.attributedTitle

        self.highlightedBackgroundView.backgroundColor = visualStyle.actionHighlightColor

        self.titleLabel.accessibilityLabel = action.attributedTitle?.string
        self.isAccessibilityElement = true
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.titleLabel.textColor = titleLabelColorFromVisualStyle ?? self.tintColor
    }
}

final class ActionSeparatorView: UICollectionReusableView {

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)

        if let attributes = layoutAttributes as? ActionsCollectionViewLayoutAttributes {
            self.backgroundColor = attributes.backgroundColor
        }
    }
}
