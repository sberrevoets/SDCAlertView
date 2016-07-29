import UIKit

final class TextFieldCell: UITableViewCell {

    @IBOutlet private var borderView: UIView!
    @IBOutlet private var textFieldContainer: UIView!

    var textField: UITextField? {
        didSet {
            oldValue?.removeFromSuperview()
            if let textField = self.textField {
                self.add(textField)
            }
        }
    }

    var visualStyle: AlertVisualStyle? {
        didSet {
            self.textField?.font = self.visualStyle?.textFieldFont
            self.borderView.backgroundColor = self.visualStyle?.textFieldBorderColor

            guard let padding = self.visualStyle?.textFieldMargins else {
                return
            }

            self.paddingConstraints?.leading.constant = padding.left
            self.paddingConstraints?.trailing.constant = -padding.right
            self.paddingConstraints?.top.constant = padding.top
            self.paddingConstraints?.bottom.constant = -padding.bottom
        }
    }

    private var paddingConstraints: (leading: NSLayoutConstraint, trailing: NSLayoutConstraint,
        top: NSLayoutConstraint, bottom: NSLayoutConstraint)?

    private func add(_ textField: UITextField) {
        let container = self.textFieldContainer
        container?.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        let insets = self.visualStyle?.textFieldMargins ?? UIEdgeInsets.zero
        let constraints = textField.sdc_alignEdges(withSuperview: .all, insets: insets) as! [NSLayoutConstraint]

        // Assumes array order to be: top, right, bottom, left (compatible with SDCAutoLayout 2.0)
        self.paddingConstraints = (leading: constraints[3], trailing: constraints[1], top: constraints[0],
            bottom: constraints[2])
    }
}
