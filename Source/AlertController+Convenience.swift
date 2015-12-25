public extension AlertController {

    /**
    Convenience method to quickly display a basic alert.

    - parameter title:       An optional title for the alert
    - parameter message:     An optional message for the alert
    - parameter actionTitle: An optional action for the alert
    - parameter customView:  An optional view that will be displayed in the alert's `contentView`

    - returns: The alert that was presented.
    */
    public class func alertWithTitle(title: String? = nil, message: String? = nil, actionTitle: String? = nil,
        customView: UIView? = nil) -> AlertController
    {
        let alertController = AlertController(title: title, message: message)
        alertController.addAction(AlertAction(title: actionTitle, style: .Preferred))

        if let customView = customView {
            alertController.contentView.addSubview(customView)
        }

        alertController.present()
        return alertController
    }

    /**
     Convenience method to quickly display a basic action sheet.

     - parameter title:   An optional title for the action sheet
     - parameter message: An optional message for the action sheet
     - parameter actions: The titles of the actions in the action sheet

     - returns: The action sheet that was presented.
     */
    public class func sheetWithTitle(title: String? = nil, message: String? = nil, actions: [String])
        -> AlertController
    {
        let alertController = AlertController(title: title, message: message, preferredStyle: .ActionSheet)
        actions.forEach { alertController.addAction(AlertAction(title: $0, style: .Default)) }
        alertController.present()
        return alertController
    }

    /**
     Convenience method to quickly display an action sheet with custom view

     - parameter view:    The view that should be displayed in the action sheet
     - parameter actions: The titles of the actions in the action sheet

     - returns: The action sheet that was presented.
     */
    public class func sheetWithView(view: UIView, actions: [String]) -> AlertController {
        let alertController = AlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        actions.forEach { alertController.addAction(AlertAction(title: $0, style: .Default)) }
        alertController.contentView.addSubview(view)
        alertController.present()
        return alertController
    }
}
