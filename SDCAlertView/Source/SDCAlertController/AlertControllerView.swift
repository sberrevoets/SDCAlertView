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

    var contentView = UIView()

    var visualStyle: VisualStyle = DefaultVisualStyle()

    private let scrollView = UIScrollView()

    private let titleLabel = AlertLabel()
    private let messageLabel = AlertLabel()
    private let actionsCollectionView = ActionsCollectionView()

    private var elements: [UIView] {
        let possibleElements: [UIView?] = [
            self.titleLabel,
            self.messageLabel,
            self.textFieldsViewController?.view,
            self.contentView.subviews.count > 0 ? self.contentView : nil,
        ]

        return possibleElements.flatMap { $0 }
    }

    private var contentHeight: CGFloat {
        guard let lastElement = self.elements.last else { return 0 }

        lastElement.layoutIfNeeded()
        return CGRectGetMaxY(lastElement.frame) + self.visualStyle.contentPadding.bottom
    }

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
        addParallax()
    }

    func setActionTappedHandler(handler: (AlertAction) -> Void) {
        self.actionsCollectionView.actionTapped = handler
    }

    // MARK: - Private methods

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
        self.heightAnchor.constraintLessThanOrEqualToAnchor(self.superview!.heightAnchor,
            constant: -(self.visualStyle.margins.top + self.visualStyle.margins.bottom)).active = true
        let totalHeight = self.contentHeight + self.actionsCollectionView.displayHeight
        let heightConstraint = self.heightAnchor.constraintEqualToConstant(totalHeight)
        heightConstraint.priority = UILayoutPriorityDefaultHigh
        heightConstraint.active = true

        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.visualStyle.cornerRadius
        self.titleLabel.font = self.visualStyle.titleLabelFont
        self.messageLabel.font = self.visualStyle.messageLabelFont
        self.textFieldsViewController?.visualStyle = self.visualStyle
    }

    // MARK: - Constraints

    private func createContentConstraints() {
        createTitleLabelConstraints()
        createMessageLabelConstraints()
        createTextFieldsConstraints()
        createCustomContentViewConstraints()
        createCollectionViewConstraints()
        createScrollViewConstraints()
    }

    private func createTitleLabelConstraints() {
        self.titleLabel.firstBaselineAnchor.constraintEqualToAnchor(self.topAnchor,
            constant: self.visualStyle.contentPadding.top).active = true
        self.titleLabel.leftAnchor.constraintEqualToAnchor(self.leftAnchor,
            constant: self.visualStyle.contentPadding.left).active = true
        self.titleLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor,
            constant: -self.visualStyle.contentPadding.right).active = true

        pinBottomOfScrollViewToView(self.titleLabel, withPriority: UILayoutPriorityDefaultLow)
    }

    private func createMessageLabelConstraints() {
        self.messageLabel.firstBaselineAnchor.constraintEqualToAnchor(self.titleLabel.lastBaselineAnchor,
            constant: self.visualStyle.verticalElementSpacing).active = true
        self.messageLabel.leftAnchor.constraintEqualToAnchor(self.leftAnchor,
            constant: self.visualStyle.contentPadding.left).active = true
        self.messageLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor,
            constant: -self.visualStyle.contentPadding.right).active = true

        pinBottomOfScrollViewToView(self.messageLabel, withPriority: UILayoutPriorityDefaultLow + 1)
    }

    private func createTextFieldsConstraints() {
        guard let textFieldsView = self.textFieldsViewController?.view else { return }

        // The text fields view controller needs the visual style to calculate its height
        self.textFieldsViewController?.visualStyle = self.visualStyle

        let height = self.textFieldsViewController?.requiredHeight
        let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right
        textFieldsView.topAnchor.constraintEqualToAnchor(self.messageLabel.lastBaselineAnchor,
            constant: self.visualStyle.verticalElementSpacing).active = true
        textFieldsView.widthAnchor.constraintEqualToAnchor(self.widthAnchor, multiplier: 1,
            constant: -widthOffset).active = true
        textFieldsView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        textFieldsView.heightAnchor.constraintEqualToConstant(height!).active = true

        pinBottomOfScrollViewToView(textFieldsView, withPriority: UILayoutPriorityDefaultLow + 2)
    }

    private func createCustomContentViewConstraints() {
        if !self.elements.contains(self.contentView) { return }

        let aligningView = self.textFieldsViewController?.view ?? self.messageLabel

        let topSpacing = self.visualStyle.verticalElementSpacing
        self.contentView.topAnchor.constraintEqualToAnchor(aligningView.bottomAnchor,
            constant: topSpacing).active = true
        self.contentView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        self.contentView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true

        pinBottomOfScrollViewToView(self.contentView, withPriority: UILayoutPriorityDefaultLow + 3)
    }

    private func createCollectionViewConstraints() {
        let actionsHeight = self.actionsCollectionView.displayHeight
        self.actionsCollectionView.heightAnchor.constraintEqualToConstant(actionsHeight).active = true
        self.actionsCollectionView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        self.actionsCollectionView.topAnchor.constraintEqualToAnchor(self.scrollView.bottomAnchor)
            .active = true
        self.actionsCollectionView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        self.actionsCollectionView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    }

    private func createScrollViewConstraints() {
        self.scrollView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        self.scrollView.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        self.scrollView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
    }

    private func pinBottomOfScrollViewToView(view: UIView, withPriority priority: UILayoutPriority) {
        let bottomAnchor = view.bottomAnchor.constraintEqualToAnchor(self.scrollView.bottomAnchor,
            constant: -self.visualStyle.contentPadding.bottom)
        bottomAnchor.priority = priority
        bottomAnchor.active = true
    }

    private func addParallax() {
        let parallax = self.visualStyle.parallax

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = NSNumber(float: Float(-parallax.horizontal))
        horizontal.maximumRelativeValue = NSNumber(float: Float(parallax.horizontal))

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        vertical.minimumRelativeValue = NSNumber(float: Float(-parallax.vertical))
        vertical.maximumRelativeValue = NSNumber(float: Float(parallax.vertical))

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]

        self.addMotionEffect(group)
    }
}
