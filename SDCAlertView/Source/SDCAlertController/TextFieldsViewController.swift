//
//  TextFieldsViewController.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/14/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

private let kTextFieldCellIdentifier = "textFieldCell"

class TextFieldsViewController: UITableViewController {

    private let textFields: [UITextField]

    var requiredHeight: CGFloat {
        return self.tableView.rowHeight * CGFloat(self.tableView.numberOfRowsInSection(0))
    }

    init(textFields: [UITextField]) {
        self.textFields = textFields
        super.init(style: .Plain)

        let nibName = NSStringFromClass(TextFieldCell).componentsSeparatedByString(".").last!
        let cellNib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: kTextFieldCellIdentifier)
        self.tableView.dataSource = self
        self.tableView.rowHeight = 25
        self.tableView.separatorStyle = .None
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(textFields: [UITextField()])
        return nil
    }
}

extension TextFieldsViewController/*: UITableViewDataSource */ {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textFields.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTextFieldCellIdentifier,
            forIndexPath: indexPath) as? TextFieldCell
        cell?.textField = self.textFields[indexPath.row]
        return cell!
    }
}
