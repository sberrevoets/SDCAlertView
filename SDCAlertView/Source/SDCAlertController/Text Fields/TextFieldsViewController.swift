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

    var requiredHeight: CGFloat {
        return self.tableView.rowHeight * CGFloat(self.tableView.numberOfRowsInSection(0))
    }

    var visualStyle: VisualStyle? {
        didSet {
            guard let visualStyle = self.visualStyle else { return }
            self.tableView.rowHeight = visualStyle.textFieldHeight
        }
    }

    private let textFields: [UITextField]

    init(textFields: [UITextField]) {
        self.textFields = textFields
        super.init(style: .Plain)

        let nibName = NSStringFromClass(TextFieldCell).componentsSeparatedByString(".").last!
        let cellNib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: kTextFieldCellIdentifier)
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.scrollEnabled = false
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
        cell?.visualStyle = self.visualStyle
        return cell!
    }
}
