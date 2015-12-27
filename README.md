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

 - Xcode 7 or higher
 - iOS 8 or higher

If you want to use the library on iOS 7, please use version 2.5.4 (the latest 2.x release). SDCAlertView is not available on iOS 6.1 or below.

# Installation

## CocoaPods
To install SDCAlertView using CocoaPods, please integrate it in your existing Podfile, or create a new Podfile:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
  pod 'SDCAlertView', '~> 4.0'
end
```

Then run `pod install`.

## Carthage
To install with Carthage, add the following line to your `Cartfile`:

```ruby
"sberrevoets/SDCAlertView" ~> 4.0
```

Run `carthage update` and drag `SDCAlertView.framework` in the `Build` folder into your project.

## Swift Package Manager
To use the Swift Package Manager, add the following to your `Package.swift` file: 

```swift
import PackageDescription

let package = Package(
    name: "<your project name>"
    dependencies: [
        .Package(url: "https://github.com/sberrevoets/SDCAlertView/SDCAlertView.git", majorVersion: 4.0)
    ])
```

# Alerts vs. Action Sheets

Starting with version 4.0, `SDCAlertController` also supports the presentation of action sheets. Some things to keep in mind when using action sheets:

- It does not properly adapt on iPad. This is because iOS doesn't support `UIModalPresentationStyle.Custom` for adaptive presentations (such as when presenting an action sheet from a bar button item).
- The new `AlertBehaviors` is, due to limitations in the Swift/Objective-C interop, not available when using `SDCAlertController` from Swift. This affects `AlertControllerStyle.Alert` as well.
- When adding subviews to the custom content view, that view will replace the title and message labels.

# Usage
`SDCAlertView` is written in Swift, but can be used in both Swift and
Objective-C. Classes in Objective-C have the same name they do in Swift, but
with an `SDC` prefix. Once Swift [supports prefixing enums](https://github.com/apple/swift/pull/618) they will also get the `SDC` prefix.

Unfortunately the Swift/Objective-C interop is not perfect, so not all functionality that's available in Swift is available in Objective-C.
## Basic

```swift
let alert = AlertController(title: "Title", message: "This is a message", preferredStyle: .Alert)
alert.addAction(AlertAction(title: "Cancel", style: .Default))
alert.addAction(AlertAction(title: "OK", style: .Preferred))
alert.present()

// or use the convenience methods:

AlertController.alertWithTitle("Title", message: "This is a message", actionTitle: "OK")
AlertController.sheetWithTitle("Action sheet title", "Action sheet message", actions: ["OK", "Cancel"])
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
alert.shouldDismissHandler = { $0.title == "Dismiss" }
alert.present()
```

## Styling and Appearance

`SDCAlertController` is a normal view controller, so applying a `tintColor` to its `view` will color the buttons and any subviews you add to the `contentView`.

If you are looking for more customizations, create a type that conforms to `VisualStyle` and use `visualStyle` on the `AlertController` instance. You can also subclass `DefaultVisualStyle` for a set of default values that you can then override as needed.

# Support
I'm pretty active on [Stack Overflow](http://stackoverflow.com/users/751268/scott-berrevoets), so please use that if you have any questions. You can also use [Twitter](http://twitter.com/ScottBerrevoets) to contact me directly.

If you are experiencing bugs, feel free to post an issue or submit a pull request.

# License

SDCAlertView is distributed under the MIT license.
