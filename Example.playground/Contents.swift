import XCPlayground
import SDCAlertView

let viewController = UIViewController()
viewController.view.backgroundColor = UIColor.whiteColor()

XCPlaygroundPage.currentPage.liveView = viewController
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

/*** Create, customize, and present your alert below ***/

let alert = AlertController(title: "Title", message: "Hey user, you're being alerted about something")
alert.addAction(AlertAction(title: "OK", style: .Preferred))
alert.present()
