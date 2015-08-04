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

    private var stackView: UIStackView! {
        didSet {
            self.stackView.axis = .Vertical
            self.stackView.alignment = .Center
            self.stackView.distribution = .EqualSpacing
        }
    }

    private var titleLabel = UILabel()
    private var messageLabel = UILabel()
    private var actionsCollectionView = ActionsCollectionView()

    var title: NSAttributedString?
    var message: NSAttributedString?
    var actions: [AlertAction] = []
    var textFieldsViewController: TextFieldsViewController?

    func prepareLayout() {
        createBackground()
        createStackView()

        self.titleLabel.attributedText = self.title
        self.messageLabel.attributedText = self.message
        self.actionsCollectionView.actions = self.actions

        self.titleLabel.hidden = self.title == nil
        self.messageLabel.hidden = self.message == nil
        self.actionsCollectionView.hidden = self.actions.count == 0
    }

    private func createBackground() {
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(backgroundView)
        alignViewToSelf(backgroundView)
    }

    private func createStackView() {
        let views = [
            self.titleLabel,
            self.messageLabel,
            self.textFieldsViewController?.view,
            self.actionsCollectionView,
        ]

        self.actionsCollectionView.heightAnchor.constraintEqualToConstant(44).active = true
        self.actionsCollectionView.widthAnchor.constraintEqualToConstant(250).active = true
        self.textFieldsViewController?.view.widthAnchor.constraintEqualToConstant(250).active = true
        let textFieldsHeight = self.textFieldsViewController?.requiredHeight
        textFieldsViewController?.view.heightAnchor.constraintEqualToConstant(textFieldsHeight!).active = true

        self.stackView = UIStackView(arrangedSubviews: views.flatMap { $0 })
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.stackView)
        alignViewToSelf(self.stackView)
    }

    private func alignViewToSelf(view: UIView) {
        view.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        view.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        view.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        view.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    }
}
