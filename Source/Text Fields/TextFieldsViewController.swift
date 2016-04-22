import UIKit

private let kTextFieldCellIdentifier = "textFieldCell"

final class TextFieldsViewController: UIViewController {

    var requiredHeight: CGFloat {
        return self.tableView.rowHeight * CGFloat(self.tableView.numberOfRowsInSection(0))
    }

    var visualStyle: AlertVisualStyle? {
        didSet {
            guard let visualStyle = self.visualStyle else { return }
            self.tableView.rowHeight = visualStyle.textFieldHeight
        }
    }

    private let tableView = UITableView(frame: .zero, style: .Plain)
    private let textFields: [UITextField]

    init(textFields: [UITextField]) {
        self.textFields = textFields
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.textFields = []
        super.init(nibName: nil, bundle: nil)
        return nil
    }

    override func loadView() {
        let nibName = NSStringFromClass(TextFieldCell).componentsSeparatedByString(".").last!
        let cellNib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: kTextFieldCellIdentifier)
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        self.tableView.scrollEnabled = false

        self.view = tableView
    }
}

extension TextFieldsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textFields.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTextFieldCellIdentifier,
            forIndexPath: indexPath) as? TextFieldCell
        cell?.textField = self.textFields[indexPath.row]
        cell?.visualStyle = self.visualStyle
        return cell!
    }
}
