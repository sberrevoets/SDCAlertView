# SDCAlertView

![CI Status](https://travis-ci.org/sberrevoets/SDCAlertView.svg?branch=master)
![CocoaPods](https://img.shields.io/cocoapods/v/SDCAlertView.svg)
![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)

`SDCAlertView` started out as an alert that looked identical to `UIAlertView`, but had support for a custom content view. With the introduction of `UIAlertController` in iOS 8, the project was updated to the more modern API that `UIAlertController` brought.

<div align="center">
    <img src="http://sberrevoets.github.io/SDCAlertView/ActionSheet.gif">
    <img src="http://sberrevoets.github.io/SDCAlertView/Alert.gif">
</div>

## Features

- [x] Most `UIAlertController` functionality
- [x] Custom content views
- [x] Preventing controllers from dismissing when the user taps a button
- [x] Easy presentation/dismissal
- [x] Attributed title label, message label, and buttons
- [x] Appearance customization
- [x] Usable from Swift and Objective-C
- [x] Understandable button placement
- [x] UI tests
- [x] Custom alert behavior
- [x] CocoaPods/Carthage/Swift Package Manager support
- [ ] Easy queueing of alerts

# Requirements

 - Swift 3
 - iOS 8 or higher

If you want to use the library on iOS 7, please use version 2.5.4 (the latest 2.x release).

# Installation

## CocoaPods
To install SDCAlertView using CocoaPods, please integrate it in your existing Podfile, or create a new Podfile:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
  pod 'SDCAlertView', '~> 7.1'
end
```

Then run `pod install`.

## Carthage
To install with Carthage, add the following line to your `Cartfile`:

```ruby
github "sberrevoets/SDCAlertView" ~> 7.1
```

Run `carthage update` and drag `SDCAlertView.framework` in the `Build` folder into your project.

## Swift Package Manager
SPM does not yet support iOS, but SDCAlertView will be available there once it does.

# Alerts vs. Action Sheets

`SDCAlertController` supports the presentation of action sheets, but there are some limitations and things to keep in mind when using action sheets:

- It does not properly adapt on iPad. This is because iOS doesn't support `UIModalPresentationStyle.Custom` for adaptive presentations (such as when presenting an action sheet from a bar button item).
- The new `AlertBehaviors` is, due to limitations in the Swift/Objective-C interop, not available when using `SDCAlertController` from Swift. This affects `AlertControllerStyle.Alert` as well.
- When adding subviews to the custom content view, that view will replace the title and message labels.

# Usage
`SDCAlertView` is written in Swift, but can be used in both Swift and Objective-C. Corresponding types in Objective-C have the same name they do in Swift, but with an `SDC` prefix.

## Basic

```swift
let alert = AlertController(title: "Title", message: "This is a message", preferredStyle: .Alert)
alert.add(AlertAction(title: "Cancel", style: .default))
alert.add(AlertAction(title: "OK", style: .preferred))
alert.present()

// or use the convenience methods:

AlertController.alert(withTitle: "Title", message: "This is a message", actionTitle: "OK")
AlertController.sheet(withTitle: "Action sheet title", "Action sheet message", actions: ["OK", "Cancel"])
```

## Custom Content Views

```swift
let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
alert.add(AlertAction(title: "Dismiss", style: .preferred))
alert.add(AlertAction(title: "Don't dismiss", style: .default))
alert.shouldDismissHandler = { $0.title == "Dismiss" }
alert.present()
```

## Styling and Appearance

`SDCAlertController` is a normal view controller, so applying a `tintColor` to its `view` will color the buttons and any subviews you add to the `contentView`.

If you are looking for more customizations, create a subclass of `AlertVisualStyle` and use `visualStyle` on the `AlertController` instance. You can also create an instance of `AlertVisualStyle` and overwrite the attributes you need (this is mainly intended to be used from Objective-C). Note that after an alert has been presented, changing any of these settings is ignored.

# Support
I'm pretty active on [Stack Overflow](http://stackoverflow.com/users/751268/scott-berrevoets), so please use that if you have any questions. If you are experiencing bugs, feel free to post an issue or submit a pull request.

# License

SDCAlertView is distributed under the MIT license.
