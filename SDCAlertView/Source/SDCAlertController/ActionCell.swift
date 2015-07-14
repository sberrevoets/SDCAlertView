//
//  ActionCell.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/13/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

class ActionCell: UICollectionViewCell {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var highlightedBackgroundView: UIView!

    var action: AlertAction? {
        didSet {
            self.titleLabel.text = self.action?.title
        }
    }

    override var highlighted: Bool {
        didSet { self.highlightedBackgroundView.hidden = !self.highlighted }
    }

    @IBAction private func cellTapped(sender: UITapGestureRecognizer) {
        guard let action = self.action else { return }
        action.handler?(action)
    }
}
