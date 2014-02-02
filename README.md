SDCAlertView
============
`SDCAlertView` doesn't just look like a system alert in terms of user interface elements, it is the result of completely reverse-engineering `UIAlertView`. View hierarchy, labels, table views, animations, user interaction; everything has been looked at and incorporated as much as possible.

You can think of `SDCAlertView` as `UIAlertView` on steroids. It has added functionality such as a `contentView` property and block syntax, while still keeping the `UIAlertView` look.

Are you sure it's the same?
==============================
Check for yourself:

![Animated GIF showing alert](http://scott90.github.io/SDCAlertView/ProgressViewAlert.gif)

What has been successfully duplicated:
--------------------------------------

- Entire `UIAlertView` public API, including `UIAlertViewDelegate`
- The dimensions and positioning of all views in all alert configurations
- Showing and dismissing animations
- Faded background, blurring, and disabling of underlying UI elements
- User interaction with alert, including parallax effect
- Font sizes and colors for labels, text fields, and buttons

What won't or can't be duplicated:
-------------------------

- Special interaction with the system. The system does not consider instances of `SDCAlertView` actual alerts, which means that, for example, the `alertViewCancel:` method from `SDCAlertViewDelegate` will never be called.

- Text field placeholders in different languages. Login and Password are entered as localized strings, but they aren't actually translated.

- Some behavior is purposely not ported from `UIAlertView`. These cases are discussed in SDCAlertView.h.

Installation
============
The easiest way to install is, of course, by using Cocoapods. The name of the pod is `SDCAlertView`.

If you're not using Cocoapods, you need at least:

- SDCAlertView.{h,m}
- SDCAlertView_Private.h
- SDCAlertViewViewController.{h,m}
- SDCAlertViewContentView.{h,m}
- SDCAlertViewBackgroundView.{h,m}
- SDCAlertViewBackground.png (for older generation iPads)
- SDCAlertViewBackground&#064;2x.png

The project also depends on [RBBAnimation](https://github.com/robb/RBBAnimation) and [SDCAutoLayout](https://github.com/Scott90/SDCAutoLayout). These dependencies are handled for you if you use Cocoapods.

Usage
=====
`SDCAlertView` is for use in iOS 7 only. It will not work properly on iOS 6.1 or below. sUsing `SDCAlertView` is simple: just import SDCAlertView.h and use it as you would `UIAlertView`. In addition to that, `SDCAlertView` has some added functionality, including:

- `contentView`. The `contentView` property can be used to add custom views to the alert. See SDCAlertView.h for details on how to use this. For sample uses, see [SDCViewController](SDCAlertView/SDCViewController.m). To use the `contentView` property, you need to use AutoLayout. [`SDCAutoLayout`](https://github.com/Scott90/SDCAutoLayout), automatically included with this project, is an `NSLayoutConstraint` that makes creating constraints a little easier.

- Block syntax. Some delegate methods have block alternatives as settable properties that you can use for simple implementations. There's also a convenient `showWithDismissHandler:` method to make handling a dismissal even easier.

- Additional delegate methods: `alertView:shouldDismissWithButtonIndex:` and `alertView:shouldDeselectButtonWithIndex:`

Questions
=========
If you have questions, please use Stack Overflow, or use [Twitter](http://twitter.com/ScottBerrevoets) to contact me directly.

Credits
=======

Some credits are in order:

- Robert Böhnke ([@robb](https://github.com/robb)) - [RBBAnimation](https://github.com/robb/RBBAnimation)
- Lee McDermott ([@lmcd](https://github.com/lmcd)) for reverse-engineering the showing and dismissing animations.
- César Castillo ([@JagCesar](https://github.com/JagCesar)) for the great idea of using a `UIToolbar` for easy live blurring