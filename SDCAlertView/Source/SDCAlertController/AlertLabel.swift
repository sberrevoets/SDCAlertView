//
//  AlertLabel.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 9/4/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

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
