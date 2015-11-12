# SDCAlertView

![CI Status](https://travis-ci.org/sberrevoets/SDCAlertView.svg?branch=master)
![CocoaPods](https://img.shields.io/cocoapods/v/SDCAlertView.svg)

`SDCAlertView` started out as an alert that looked identical to `UIAlertView`, but had support for a custom content view. With the introduction of `UIAlertController` in iOS 8, the project was updated to the more modern API that `UIAlertController` brought.

<p align="center">
<img src="http://sberrevoets.github.io/SDCAlertView/SDCAlertView.gif">
</p>

**Note:** While `UIAlertController` supports the action sheet style alert (previously `UIActionSheet`), SDCAlertView/SDCAlertController do not support this.

## Features

- [x] Most `UIAlertController` functionality
- [x] Custom content views
- [x] Preventing an alert from dismissing when the user taps a button
- [x] Easy presentation/dismissal
- [x] Attributed title label, message label, and buttons
- [x] Alert appearance customization
- [x] Usable from Swift and Objective-C
- [x] Understandable button placement
- [x] UI tests
- [ ] Carthage support
- [ ] Easy queueing of alerts
- [ ] Custom alert behavior

# Requirements

 - Xcode 7 or higher
 - iOS 8 or higher

If you want to use the library on iOS 7, please use version 2.5.4 (the latest 2.x release). SDCAlertView is not available on iOS 6.1 or below.

# Installation

To install SDCAlertView using CocoaPods, please integrate it in your existing Podfile, or create a new Podfile:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
  pod 'SDCAlertView', '~> 3.0'
end
```

Then run `pod install`.

# Usage
`SDCAlertView` is written in Swift, but can be used in both Swift and Objective-C.

## Basic

```swift
let alert = AlertController(title: "Title", message: "This is a message")
alert.addAction(AlertAction(title: "Cancel", style: .Default))
alert.addAction(AlertAction(title: "OK", style: .Preferred))
alert.present()

// or use the convenience method:

AlertController.showWithTitle("Title", message: "This is a message", actionTitle: "OK")
```

## Custom Content Views

```swift
let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
spinner.translatesAutoresizingMaskIntoConstraints = false
spinner.startAnimating()

let alert = AlertController(title: "Title", message: "Please wait...")
alert.contentView.addSubview(spinner)

spinner.centerXAnchor.constraintEqualToAnchor(alert.contentView.centerXAnchor).active = true
spinner.topAnchor.constraintEqualToAnchor(alert.contentView.topAnchor).active = true
spinner.bottomAnchor.constraintEqualToAnchor(alert.contentView.bottomAnchor).active = true

alert.present()
```

## Dismissal Prevention

```swift
let alert = AlertController(title: "Title", message: "This is a message")
alert.addAction(AlertAction(title: "Dismiss", style: .Preferred))
alert.addAction(AlertAction(title: "Don't dismiss", style: .Default))
alert.setShouldDismissHandler { $0.title == "Dismiss" }
alert.present()
```

## Styling and Appearance

`SDCAlertController` is a normal view controller, so applying a `tintColor` to its `view` will color the buttons and any subviews you add to the `contentView`.

If you are looking for more customizations, create a type that conforms to `VisualStyle` and use `setVisualStyle()` on the `AlertController` instance. You can also subclass `DefaultVisualStyle` for a set of default values that you can then override as needed.

# Support
I'm pretty active on [Stack Overflow](http://stackoverflow.com/users/751268/scott-berrevoets), so please use that if you have any questions. You can also use [Twitter](http://twitter.com/ScottBerrevoets) to contact me directly.

If you are experiencing bugs, feel free to post an issue or submit a pull request. I don't bite, promise!

# License

SDCAlertView is distributed under the MIT license.
