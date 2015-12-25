import UIKit

@objc(SDCAlertLabel)
class AlertLabel: UILabel {

    init() {
        super.init(frame: .zero)
        self.textAlignment = .Center
        self.numberOfLines = 0
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        self.preferredMaxLayoutWidth = self.bounds.width
        super.layoutSubviews()
    }
}
