import UIKit

@objc(SDCAlertLabel)
public class AlertLabel: UILabel {

    init() {
        super.init(frame: .zero)
        self.textAlignment = .Center
        self.numberOfLines = 0
    }

    public convenience required init?(coder aDecoder: NSCoder) {
        self.init()
    }

    public override func layoutSubviews() {
        self.preferredMaxLayoutWidth = self.bounds.width
        super.layoutSubviews()
    }
}
