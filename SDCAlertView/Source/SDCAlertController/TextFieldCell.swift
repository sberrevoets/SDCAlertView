//
//  TextFieldCell.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/14/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet private var borderView: UIView!
    @IBOutlet private var textFieldContainer: UIView!

    var textField: UITextField? {
        didSet {
            oldValue?.removeFromSuperview()
            textField.map(addTextField)
        }
    }

    private func addTextField(textField: UITextField) {
        let container = self.textFieldContainer
        container.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        textField.leadingAnchor.constraintEqualToAnchor(container.leadingAnchor, constant: 4).active = true
        textField.trailingAnchor.constraintEqualToAnchor(container.trailingAnchor, constant: 4).active = true
        textField.topAnchor.constraintEqualToAnchor(container.topAnchor, constant: 4).active = true
        textField.bottomAnchor.constraintEqualToAnchor(container.bottomAnchor, constant: 4).active = true
    }
}
