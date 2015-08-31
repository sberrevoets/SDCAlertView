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

    private let scrollView = UIScrollView()

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionsCollectionView = ActionsCollectionView()

    private var elements: [UIView] {
        return [
            self.titleLabel,
            self.messageLabel,
            self.textFieldsViewController?.view,
        ].flatMap { $0 }
    }

    private var contentHeight: CGFloat {
        guard let lastElement = self.elements.last else { return 0 }

        lastElement.layoutIfNeeded()
        return CGRectGetMaxY(lastElement.frame) + self.visualStyle.contentPadding.bottom
    }

    var title: NSAttributedString? {
        get { return self.titleLabel.attributedText }
        set { self.titleLabel.attributedText = newValue }
    }

    var message: NSAttributedString? {
        get { return self.messageLabel.attributedText }
        set { self.messageLabel.attributedText = newValue }
    }

    var actions: [AlertAction] = []
    var actionLayout: ActionLayout = .Automatic

    var textFieldsViewController: TextFieldsViewController?

    var visualStyle: VisualStyle = DefaultVisualStyle()

    func prepareLayout() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.scrollView)

        self.actionsCollectionView.actions = self.actions
        self.actionsCollectionView.visualStyle = self.visualStyle
        updateCollectionViewScrollDirection()

        createBackground()
        createUI()
        createContentConstraints()
        updateUI()
    }

    private func createUI() {
        for element in self.elements {
            element.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(element)
        }

        self.actionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.actionsCollectionView)
    }

    private func createBackground() {
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        self.insertSubview(backgroundView, belowSubview: self.scrollView)
        backgroundView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        backgroundView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        backgroundView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        backgroundView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
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

    private func updateUI() {
        self.widthAnchor.constraintEqualToConstant(self.visualStyle.width).active = true
        let totalHeight = self.contentHeight + self.actionsCollectionView.displayHeight
        self.heightAnchor.constraintEqualToConstant(totalHeight).active = true

        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.visualStyle.cornerRadius
        self.titleLabel.font = self.visualStyle.titleLabelFont
        self.messageLabel.font = self.visualStyle.messageLabelFont
        self.textFieldsViewController?.visualStyle = self.visualStyle
    }

    // MARK: Constraints

    private func createContentConstraints() {
        createTitleLabelConstraints()
        createMessageLabelConstraints()
        createTextFieldsConstraints()
        createCollectionViewConstraints()
        createScrollViewConstraints()
    }

    private func createTitleLabelConstraints() {
        self.titleLabel.firstBaselineAnchor.constraintEqualToAnchor(self.topAnchor,
            constant: self.visualStyle.contentPadding.top).active = true
        self.titleLabel.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
    }

    private func createMessageLabelConstraints() {
        self.messageLabel.firstBaselineAnchor.constraintEqualToAnchor(self.titleLabel.lastBaselineAnchor,
            constant: self.visualStyle.labelSpacing).active = true
        self.messageLabel.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
    }

    private func createTextFieldsConstraints() {
        guard let textFieldsView = self.textFieldsViewController?.view else { return }

        // The text fields view controller needs the visual style to calculate its height
        self.textFieldsViewController?.visualStyle = self.visualStyle

        let textFieldsHeight = self.textFieldsViewController?.requiredHeight
        let textFieldMargins = self.visualStyle.textFieldMargins
        let textFieldsWidthOffset = textFieldMargins.left + textFieldMargins.right
        textFieldsView.topAnchor.constraintEqualToAnchor(self.messageLabel.lastBaselineAnchor,
            constant: self.visualStyle.messageLabelBottomSpacing).active = true
        textFieldsView.widthAnchor.constraintEqualToAnchor(self.widthAnchor, multiplier: 1,
            constant: -textFieldsWidthOffset).active = true
        textFieldsView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        textFieldsView.heightAnchor.constraintEqualToConstant(textFieldsHeight!).active = true
    }

    private func createCollectionViewConstraints() {
        let actionsHeight = self.actionsCollectionView.displayHeight
        self.actionsCollectionView.heightAnchor.constraintEqualToConstant(actionsHeight).active = true
        self.actionsCollectionView.topAnchor.constraintEqualToAnchor(self.scrollView.bottomAnchor)
            .active = true
        self.actionsCollectionView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        self.actionsCollectionView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
    }

    private func createScrollViewConstraints() {
        self.scrollView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        self.scrollView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        self.scrollView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true

        let heightConstraint = self.scrollView.heightAnchor.constraintEqualToConstant(self.contentHeight)
        heightConstraint.priority = UILayoutPriorityDefaultHigh
        heightConstraint.active = true
    }
}
