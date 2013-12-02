SDCAlertView
============
`SDCAlertView` is intended as a pixel-for-pixel `UIAlertView` duplicate in iOS 7, with added functionality that a particular company at a particular developer's conference promised, but never delivered. Most importantly, `SDCAlertView` **adds support for custom content using the** `contentView` **property**.

`SDCAlertView` doesn't just look like a system alert in terms of user interface elements, it is the result of completely reverse-engineering `UIAlertView`. The view hierarchy, labels, table views, animations, everything has been looked at and incorporated as much as possible.

Are you sure it's the same?
==============================
Check for yourself:

![Animated GIF showing alert](http://scott90.github.io/SDCAlertView/ProgressViewAlert.gif)

What has been successfully duplicated:
--------------------------------------

- Entire `UIAlertView` public API, including `UIAlertViewDelegate`
- The dimensions and positioning of all views in all alert configurations
- Font sizes for labels, text fields, and buttons
- User interaction with alert, including parallax effect
- Showing and dismissing animations
- Faded background and disabling of underlying UI elements

What won't be duplicated:
-------------------------

- Special interaction with the system. The system does not consider instances of `SDCAlertView` actual alerts, which means that, for example, the `alertViewCancel:` method from `SDCAlertViewDelegate` will never be called.

- Text field placeholders in different languages. Login and Password are entered as localized strings, but they aren't actually translated.

What is not implemented yet:
----------------------------
`UIAlertView` features that are not yet implemented:

- Creating a "queue" of alerts and making sure they interact properly
- Handle device rotations correctly

Features that will enhance `SDCAlertView`:

- Block-based syntax
- Easy creation/showing

Usage
=====
The usage is almost exactly the same as it is for `UIAlertView`. Most documentation that applies to some `UIAlertView` API, also applies to the same `SDCAlertView` API. There are a few exceptions, please see SDCAlertView.h for details.

To use the `contentView` property, you have to apply auto-layout constraints to it and its subviews. The `contentView` property will be the same width as the alert, but the height is dependent on its content, so you have to set that too. See [SDCViewController](SDCAlertView/SDCViewController.m) for a few examples of how to use `contentView`. See [`SDCAutoLayout`](https://github.com/Scott90/SDCAutoLayout) for an `NSLayoutConstraint` category that makes creating constraints a little easier.

Installation
============
The easiest way to install is, of course, by using Cocoapods. The name of the pod is `SDCAlertView`.

If you're not using Cocoapods, you need at least:

- SDCAlertView.{h,m}
- SDCAlertViewViewController.{h,m}
- SDCAlertViewContentView.{h,m}
- SDCAlertViewBackgroundView.{h,m}
- SDCAlertViewBackground.png (for older generation iPads)
- SDCAlertViewBackground&#064;2x.png

The project also depends on [RBBAnimation](https://github.com/robb/RBBAnimation) and [SDCAutoLayout](https://github.com/Scott90/SDCAutoLayout). These dependencies are handled for you if you use Cocoapods.


Credits
=======

Some credits are in order:

- Robert Böhnke ([@robb](https://github.com/robb)) - [RBBAnimation](https://github.com/robb/RBBAnimation)
- Lee McDermott ([@lmcd](https://github.com/lmcd)) for reverse-engineering the showing and dismissing animations.
- César Castillo ([@JagCesar](https://github.com/JagCesar)) for the great idea of using a `UIToolbar` for easy live blurring