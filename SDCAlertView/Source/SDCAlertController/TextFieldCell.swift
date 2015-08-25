//
//  TextFieldCell.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/14/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

final class TextFieldCell: UITableViewCell {

    @IBOutlet private var borderView: UIView!
    @IBOutlet private var textFieldContainer: UIView!

    var textField: UITextField? {
        didSet {
            oldValue?.removeFromSuperview()
            if let textField = self.textField {
                addTextField(textField)
            }
        }
    }

    var visualStyle: VisualStyle? {
        didSet {
            self.textField?.font = self.visualStyle?.textFieldFont
            self.borderView.backgroundColor = self.visualStyle?.textFieldBorderColor

            guard let padding = self.visualStyle?.textFieldMargins else { return }
            self.paddingConstraints?.leading.constant = padding.left
            self.paddingConstraints?.trailing.constant = padding.right
            self.paddingConstraints?.top.constant = padding.top
            self.paddingConstraints?.bottom.constant = padding.bottom
        }
    }

    private var paddingConstraints: (leading: NSLayoutConstraint, trailing: NSLayoutConstraint,
        top: NSLayoutConstraint, bottom: NSLayoutConstraint)?

    private func addTextField(textField: UITextField) {
        let container = self.textFieldContainer
        container.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        let padding = self.visualStyle?.textFieldMargins ?? UIEdgeInsetsZero

        let leading = textField.leadingAnchor.constraintEqualToAnchor(container.leadingAnchor,
            constant: padding.left)
        let trailing = textField.trailingAnchor.constraintEqualToAnchor(container.trailingAnchor,
            constant: padding.right)
        let top = textField.topAnchor.constraintEqualToAnchor(container.topAnchor, constant: padding.top)
        let bottom = textField.bottomAnchor.constraintEqualToAnchor(container.bottomAnchor,
            constant: padding.bottom)

        leading.active = true
        trailing.active = true
        top.active = true
        bottom.active = true

        self.paddingConstraints = (leading: leading, trailing: trailing, top: top, bottom: bottom)
    }
}
