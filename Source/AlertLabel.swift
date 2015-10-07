import UIKit

@objc(SDCAlertLabel)
class AlertLabel: UILabel {

    init() {
        super.init(frame: .zero)
        self.textAlignment = .Center
        self.numberOfLines = 0
    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
    }

    override func layoutSubviews() {
        self.preferredMaxLayoutWidth = self.bounds.width
        super.layoutSubviews()
    }
}
