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

    var visualStyle: VisualStyle = DefaultVisualStyle()
    var actionLayout: ActionLayout = .Automatic

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

        self.actionsCollectionView.visualStyle = self.visualStyle
        updateCollectionViewScrollDirection()


        self.titleLabel.attributedText = self.title
        self.messageLabel.attributedText = self.message
        self.actionsCollectionView.actions = self.actions

        self.titleLabel.hidden = self.title == nil
        self.messageLabel.hidden = self.message == nil
        self.actionsCollectionView.hidden = self.actions.count == 0

        createBackground()
        createStackView()
    }

    private func createBackground() {
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        self.insertSubview(backgroundView, belowSubview: self.scrollView)
        alignView(backgroundView, toView: self)
    }

    private func createStackView() {
        self.stackView = UIStackView(arrangedSubviews: self.elements)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        self.scrollView.addSubview(self.stackView)
        createConstraints()
    }

    private func createConstraints() {
        alignView(self.stackView, toView: self.scrollView)

        let heightConstraint = self.scrollView.heightAnchor.constraintEqualToConstant(self.contentHeight)
        heightConstraint.priority = UILayoutPriorityDefaultHigh
        heightConstraint.active = true

        let actionsHeight = self.actionsCollectionView.displayHeight
        self.actionsCollectionView.heightAnchor.constraintEqualToConstant(actionsHeight).active = true
        self.actionsCollectionView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        self.textFieldsViewController?.view.widthAnchor.constraintEqualToConstant(250).active = true
        let textFieldsHeight = self.textFieldsViewController?.requiredHeight
        textFieldsViewController?.view.heightAnchor.constraintEqualToConstant(textFieldsHeight!).active = true
    }

    private func alignView(firstView: UIView, toView secondView: UIView) {
        firstView.leadingAnchor.constraintEqualToAnchor(secondView.leadingAnchor).active = true
        firstView.trailingAnchor.constraintEqualToAnchor(secondView.trailingAnchor).active = true
        firstView.topAnchor.constraintEqualToAnchor(secondView.topAnchor).active = true
        firstView.bottomAnchor.constraintEqualToAnchor(secondView.bottomAnchor).active = true
    }

    private func updateCollectionViewScrollDirection() {
        guard let layout = self.actionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
            else { return }

        if self.actionLayout == .Horizontal || (self.actions.count == 2 && self.actionLayout == .Automatic) {
            layout.scrollDirection = .Horizontal
        } else {
            layout.scrollDirection == .Vertical
        }
    }
}
