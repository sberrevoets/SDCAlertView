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

    @IBOutlet private var actionsCollectionView: ActionsCollectionView!
    @IBOutlet private var textFieldsViewController: TextFieldsViewController!

    var title: NSAttributedString?
    var message: NSAttributedString?
    var actions: [AlertAction] = []

    func prepareLayout() {
        self.titleLabel.attributedText = self.title
        self.messageLabel.attributedText = self.message
        self.actionsCollectionView.actions = self.actions

        self.titleLabel.hidden = self.title == nil
        self.messageLabel.hidden = self.message == nil
        self.actionsCollectionView.hidden = self.actions.count == 0

    }
}
