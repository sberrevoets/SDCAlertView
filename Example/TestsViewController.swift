import SDCAlertView

@available(iOS 9, *)
class TestsViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
            case 0:
                AlertController.alert(withTitle: "Title", message: "Message", actionTitle: "OK")

            case 1, 3:
                let alert = AlertController(title: "Title", message: "Message")
                alert.add(AlertAction(title: "OK", style: .normal))
                alert.add(AlertAction(title: "Cancel", style: .preferred))
                alert.present()

            case 2:
                let alert = AlertController(title: "Title", message: "Message")
                alert.add(AlertAction(title: "OK", style: .normal))
                alert.add(AlertAction(title: "Cancel", style: .preferred))
                alert.shouldDismissHandler = { $0?.title == "Cancel" }
                alert.present()

            case 4:
                let alert = AlertController(title: "Title", message: "Message")
                alert.add(AlertAction(title: "OK", style: .normal))
                alert.add(AlertAction(title: "Cancel", style: .preferred))
                alert.add(AlertAction(title: "Button", style: .normal))
                alert.present()

            case 5:
                let alert = AlertController(title: "Title", message: "Message")
                alert.actionLayout = .vertical
                alert.add(AlertAction(title: "OK", style: .normal))
                alert.add(AlertAction(title: "Cancel", style: .preferred))
                alert.present()

            case 6:
                let alert = AlertController(title: "Title", message: "Message")
                alert.actionLayout = .horizontal
                alert.add(AlertAction(title: "OK", style: .normal))
                alert.add(AlertAction(title: "Cancel", style: .preferred))
                alert.add(AlertAction(title: "Button", style: .normal))
                alert.present()

            case 7:
                let alert = AlertController(title: "Title", message: "Message")
                alert.addTextField { textField in
                    textField.text = "Sample text"
                }
                alert.add(AlertAction(title: "OK", style: .preferred))
                alert.present()

            case 8:
                let alert = AlertController(title: "Title", message: "Message")
                let contentView = alert.contentView
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                spinner.translatesAutoresizingMaskIntoConstraints = false
                spinner.startAnimating()
                contentView.addSubview(spinner)
                spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                spinner.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
                spinner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
                alert.present()

            case 9:
                let alert = AlertController(title: "Title", message: "Message")
                let action = AlertAction(title: "OK", style: .normal)
                action.accessibilityIdentifier = "button"
                alert.add(action)
                alert.present()

            case 10:
                let alert = AlertController(title: "Title", message: "Message", preferredStyle: .actionSheet)
                let action = AlertAction(title: "OK", style: .normal)
                action.accessibilityIdentifier = "button"
                alert.add(action)
                alert.present()
            
            default: break
        }
    }

}
