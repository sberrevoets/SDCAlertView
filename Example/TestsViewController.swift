import SDCAlertView

@available(iOS 9, *)
class TestsViewController: UITableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
            case 0:
                AlertController.alertWithTitle("Title", message: "Message", actionTitle: "OK")

            case 1, 3:
                let alert = AlertController(title: "Title", message: "Message")
                alert.addAction(AlertAction(title: "OK", style: .Default))
                alert.addAction(AlertAction(title: "Cancel", style: .Preferred))
                alert.present()

            case 2:
                let alert = AlertController(title: "Title", message: "Message")
                alert.addAction(AlertAction(title: "OK", style: .Default))
                alert.addAction(AlertAction(title: "Cancel", style: .Preferred))
                alert.shouldDismissHandler = { $0?.title == "Cancel" }
                alert.present()

            case 4:
                let alert = AlertController(title: "Title", message: "Message")
                alert.addAction(AlertAction(title: "OK", style: .Default))
                alert.addAction(AlertAction(title: "Cancel", style: .Preferred))
                alert.addAction(AlertAction(title: "Button", style: .Default))
                alert.present()

            case 5:
                let alert = AlertController(title: "Title", message: "Message")
                alert.actionLayout = .Vertical
                alert.addAction(AlertAction(title: "OK", style: .Default))
                alert.addAction(AlertAction(title: "Cancel", style: .Preferred))
                alert.present()

            case 6:
                let alert = AlertController(title: "Title", message: "Message")
                alert.actionLayout = .Horizontal
                alert.addAction(AlertAction(title: "OK", style: .Default))
                alert.addAction(AlertAction(title: "Cancel", style: .Preferred))
                alert.addAction(AlertAction(title: "Button", style: .Default))
                alert.present()

            case 7:
                let alert = AlertController(title: "Title", message: "Message")
                alert.addTextFieldWithConfigurationHandler { textField in
                    textField.text = "Sample text"
                }
                alert.addAction(AlertAction(title: "OK", style: .Preferred))
                alert.present()

            case 8:
                let alert = AlertController(title: "Title", message: "Message")
                let contentView = alert.contentView
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
                spinner.translatesAutoresizingMaskIntoConstraints = false
                spinner.startAnimating()
                contentView.addSubview(spinner)
                spinner.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
                spinner.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
                spinner.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
                alert.present()
            
            default: break
        }
    }

}
