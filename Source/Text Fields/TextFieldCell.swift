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

        let leading = textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left)
        let trailing = textField.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                           constant: insets.right)
        let top = textField.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top)
        let bottom = textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: insets.bottom)
        self.paddingConstraints = (leading: leading, trailing: trailing, top: top, bottom: bottom)

        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
}
