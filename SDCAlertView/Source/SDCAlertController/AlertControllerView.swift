//
//  AlertControllerView.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/12/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

@available(iOS 9, *)
class AlertControllerView: UIView {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!

    convenience init(title: NSAttributedString? = nil, message: NSAttributedString? = nil) {
        self.init(frame: CGRectZero)
        self.title = title
        self.message = message

        loadAlertViewFromNIB()
    }

    var title: NSAttributedString?
    var message: NSAttributedString?

    private func loadAlertViewFromNIB() {
        let className = "AlertControllerView"//NSStringFromClass(self.dynamicType)
        let nib = NSBundle(forClass: self.dynamicType).loadNibNamed(className, owner: self, options: nil)
        if let view = nib.first as? UIView {
            addSubview(view)
            view.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
            view.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
            view.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
            view.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        }
    }

    func prepareLayout() {
        self.titleLabel.attributedText = self.title
        self.titleLabel.hidden = self.title == nil
        self.messageLabel.attributedText = self.message
        self.messageLabel.hidden = self.message == nil
    }
}
