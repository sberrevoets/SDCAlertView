import UIKit
import SDCAlertView

final class DemoViewController: UITableViewController {

    @IBOutlet private var typeControl: UISegmentedControl!
    @IBOutlet private var styleControl: UISegmentedControl!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var messageTextField: UITextField!
    @IBOutlet private var textFieldCountTextField: UITextField!
    @IBOutlet private var buttonCountTextField: UITextField!
    @IBOutlet private var buttonLayoutControl: UISegmentedControl!
    @IBOutlet private var contentControl: UISegmentedControl!

    @IBAction private func presentAlert() {
        if self.typeControl.selectedSegmentIndex == 0 {
            self.presentSDCAlertController()
        } else {
            self.presentUIAlertController()
        }
    }

    private func presentSDCAlertController() {
        let title = self.titleTextField.content
        let message = self.messageTextField.content
        let style = AlertControllerStyle(rawValue: self.styleControl.selectedSegmentIndex)!
        let alert = AlertController(title: title, message: message, preferredStyle: style)

        let textFields = Int(self.textFieldCountTextField.content ?? "0")!
        for _ in 0..<textFields {
            alert.addTextFieldWithConfigurationHandler()
        }

        let buttons = Int(self.buttonCountTextField.content ?? "0")!
        for i in 0..<buttons {
            if i == 0 {
                alert.addAction(AlertAction(title: "Cancel", style: .Preferred))
            } else if i == 1 {
                alert.addAction(AlertAction(title: "OK", style: .Default))
            } else if i == 2 {
                alert.addAction(AlertAction(title: "Delete", style: .Destructive))
            } else {
                alert.addAction(AlertAction(title: "Button \(i)", style: .Default))
            }
        }

        alert.actionLayout = ActionLayout(rawValue: self.buttonLayoutControl.selectedSegmentIndex)!

        if #available(iOS 9, *) {
            addContentToAlert(alert)
        }
        alert.present()
    }

    @available(iOS 9, *)
    private func addContentToAlert(alert: AlertController) {
        switch self.contentControl.selectedSegmentIndex {
            case 1:
                let contentView = alert.contentView
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                spinner.translatesAutoresizingMaskIntoConstraints = false
                spinner.startAnimating()
                contentView.addSubview(spinner)
                spinner.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
                spinner.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
                spinner.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
            case 2:
                let contentView = alert.contentView
                let switchControl = UISwitch()
                switchControl.on = true
                switchControl.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(switchControl)
                switchControl.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
                switchControl.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
                switchControl.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true

                alert.message = "Disable switch to prevent alert dismissal"

                alert.shouldDismissHandler = { [unowned switchControl] _ in
                    return switchControl.on
                }
            case 3:
                let bar = UIProgressView(progressViewStyle: .Default)
                bar.translatesAutoresizingMaskIntoConstraints = false
                alert.contentView.addSubview(bar)
                bar.leadingAnchor.constraintEqualToAnchor(alert.contentView.leadingAnchor,
                    constant: 20).active = true
                bar.trailingAnchor.constraintEqualToAnchor(alert.contentView.trailingAnchor,
                    constant: -20).active = true
                bar.topAnchor.constraintEqualToAnchor(alert.contentView.topAnchor).active = true
                bar.bottomAnchor.constraintEqualToAnchor(alert.contentView.bottomAnchor).active = true

                NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector:
                    #selector(updateProgressBar), userInfo: bar, repeats: true)
            default: break
        }
    }

    @objc
    private func updateProgressBar(timer: NSTimer) {
        let bar = timer.userInfo as? UIProgressView
        bar?.progress += 0.005

        if bar?.progress >= 1 {
            timer.invalidate()
        }
    }

    private func presentUIAlertController() {
        let title = self.titleTextField.content
        let message = self.messageTextField.content
        let style = UIAlertControllerStyle(rawValue: self.styleControl.selectedSegmentIndex)!
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)

        let textFields = Int(self.textFieldCountTextField.content ?? "0")!
        for _ in 0..<textFields {
            alert.addTextFieldWithConfigurationHandler(nil)
        }

        let buttons = Int(self.buttonCountTextField.content ?? "0")!
        for i in 0..<buttons {
            if i == 0 {
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            } else if i == 1 {
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            } else if i == 2 {
                alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: nil))
            } else {
                alert.addAction(UIAlertAction(title: "Button \(i)", style: .Default, handler: nil))
            }
        }

        presentViewController(alert, animated: true, completion: nil)
    }
}

private extension UITextField {

    var content: String? {
        if let text = self.text where !text.isEmpty {
            return text
        }

        return self.placeholder
    }
}
