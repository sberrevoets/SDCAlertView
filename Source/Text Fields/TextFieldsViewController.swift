import UIKit

private let kTextFieldCellIdentifier = "textFieldCell"

final class TextFieldsViewController: UIViewController {

    var requiredHeight: CGFloat {
        return self.tableView.rowHeight * CGFloat(self.tableView.numberOfRows(inSection: 0))
    }

    var visualStyle: AlertVisualStyle? {
        didSet { self.tableView.rowHeight = visualStyle?.textFieldHeight ?? self.tableView.rowHeight }
    }

    private let tableView = UITableView(frame: .zero, style: .plain)
    fileprivate let textFields: [UITextField]

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
        let nibName = String(describing: TextFieldCell.self)
        let cellNib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        self.tableView.register(cellNib, forCellReuseIdentifier: kTextFieldCellIdentifier)
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false

        self.view = tableView
    }
}

extension TextFieldsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textFields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTextFieldCellIdentifier,
            for: indexPath) as? TextFieldCell
        cell?.textField = self.textFields[(indexPath as NSIndexPath).row]
        cell?.visualStyle = self.visualStyle
        return cell!
    }
}
