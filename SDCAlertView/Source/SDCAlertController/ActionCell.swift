//
//  ActionCell.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/13/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

final class ActionCell: UICollectionViewCell {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var highlightedBackgroundView: UIView!

    var action: AlertAction? {
        didSet { self.titleLabel.text = self.action?.title }
    }

    override var highlighted: Bool {
        didSet { self.highlightedBackgroundView.hidden = !self.highlighted }
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
