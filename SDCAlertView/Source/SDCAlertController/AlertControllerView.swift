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

    private var scrollView = UIScrollView()

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

    private var elements: [UIView] {
        return [
            self.titleLabel,
            self.messageLabel,
            self.textFieldsViewController?.view,
            self.actionsCollectionView,
        ].flatMap { $0 }
    }

    private var contentHeight: CGFloat {
        guard let lastElement = self.elements.last else { return 0 }

        lastElement.layoutIfNeeded()
        return CGRectGetMaxY(lastElement.frame)
    }

    var title: NSAttributedString?
    var message: NSAttributedString?
    var actions: [AlertAction] = []
    var textFieldsViewController: TextFieldsViewController?

    func prepareLayout() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.scrollView)
        alignView(self.scrollView, toView: self)

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

        self.insertSubview(backgroundView, belowSubview: self.scrollView)
        alignView(backgroundView, toView: self)
    }

    private func createStackView() {
        self.actionsCollectionView.heightAnchor.constraintEqualToConstant(44).active = true
        self.actionsCollectionView.widthAnchor.constraintEqualToConstant(250).active = true
        self.textFieldsViewController?.view.widthAnchor.constraintEqualToConstant(250).active = true
        let textFieldsHeight = self.textFieldsViewController?.requiredHeight
        textFieldsViewController?.view.heightAnchor.constraintEqualToConstant(textFieldsHeight!).active = true

        self.stackView = UIStackView(arrangedSubviews: self.elements)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        self.scrollView.addSubview(self.stackView)
        alignView(self.stackView, toView: self.scrollView)

        let heightConstraint = self.scrollView.heightAnchor.constraintEqualToConstant(self.contentHeight)
        heightConstraint.priority = UILayoutPriorityDefaultHigh
        heightConstraint.active = true
    }

    private func alignView(firstView: UIView, toView secondView: UIView) {
        firstView.leadingAnchor.constraintEqualToAnchor(secondView.leadingAnchor).active = true
        firstView.trailingAnchor.constraintEqualToAnchor(secondView.trailingAnchor).active = true
        firstView.topAnchor.constraintEqualToAnchor(secondView.topAnchor).active = true
        firstView.bottomAnchor.constraintEqualToAnchor(secondView.bottomAnchor).active = true
    }
}
