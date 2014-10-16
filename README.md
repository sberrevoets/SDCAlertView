# SDCAlertView

`SDCAlertView` doesn't just look like a system alert in terms of user interface elements, it is the result of completely reverse-engineering `UIAlertView`. View hierarchy, labels, buttons, animations, user interaction; everything has been looked at and incorporated as much as possible.

You can think of `SDCAlertView` as `UIAlertView` on steroids. It has added functionality such as a `contentView` property and block syntax, while still keeping the `UIAlertView` look.

![SDCAlertController](http://sberrevoets.github.io/SDCAlertView/SDCAlertController.png)

## iOS 8 & `UIAlertController`
In iOS 8, `UIAlertView` was deprecated in favor of `UIAlertController`. `SDCAlertView` was also updated to include `SDCAlertController`, whose API matches its `UI` counterpart.

But that wasn't all, the entire view hierarchy changed again and even the way of presenting the alert changed. Fortunately, the new implementation was a lot easier to copy, though some sacrifices had to be made in terms of likeness. The culprits, two private classes by the name of `_UIBackdropView` and `_UIBlendingHighlightView`, were used quite a bit, and although `UIVisualEffectView` comes close to making it look exactly right, there are differences.

Ignoring minor differences (that you would really only see if you looked for them), everything that was possible in `SDCAlertView` is also possible in `SDCAlertController`, though probably in the form of a new API. `SDCAlertController` is backwards compatible with `SDCAlertView`, meaning you can replace your existing `SDCAlertView` instances with `SDCAlertController` instances, even if your deployment target is iOS 7.

**This means that you should rarely use `SDCAlertView` anymore. Consider it, just like `UIAlertView`, deprecated and only use `SDCAlertController` moving forward. If you want to keep using `SDCAlertView` because it has functionality `SDCAlertController` does not, open an issue. This is considered a bug.**

## Installation
The easiest way to install is, of course, by using CocoaPods. The name of the pod is `SDCAlertView`.

If you're not using CocoaPods, you need all classes in the [Source](https://github.com/sberrevoets/SDCAlertView/tree/master/SDCAlertView/Source) directory.

The project also depends on [RBBAnimation](https://github.com/robb/RBBAnimation) (`SDCAlertView` only) and [SDCAutoLayout](https://github.com/sberrevoets/SDCAutoLayout). These dependencies are automatically handled for you if you use CocoaPods.

## Usage
`SDCAlertController` is for use in iOS 7 or higher only. It will not work properly on iOS 6.1 or below. Using the library is very simple: just import SDCAlertController.h and use it as you would `UIAlertController`.

### Basic

Showing a basic `SDCAlertController` alert looks just like showing a basic `UIAlertController` alert:
```objc
SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:@"Title"
																 message:@"This is a message"
														  preferredStyle:SDCAlertControllerStyleAlert];
[alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];
[alert presentWithCompletion:nil];
```

Or you can use one of the convenience methods:
```objc
[SDCAlertController showAlertControllerWithTitle:@"Title" message:@"This is a message" actionTitle:@"OK"]
```

### `contentView`

Of course, you're not using `SDCAlertView`'s full potential unless you are using the `contentView`:
```objc
SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:@"Title"
																 message:@"This is a message"
														  preferredStyle:SDCAlertControllerStyleAlert];
[alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];

UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
[spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
[spinner startAnimating];

[alert.contentView addSubview:spinner];
[spinner sdc_horizontallyCenterInSuperview];
[alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[spinner]-|"
																		  options:0
																		  metrics:nil
																			views:NSDictionaryOfVariableBindings(spinner)]];

[alert presentWithCompletion:nil];
```

### Dismissal Prevention

You can use the `shouldDismissBlock` to prevent an alert from being dismissed:

```objc
SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:@"Title"
																 message:@"This is a message"
														  preferredStyle:SDCAlertControllerStyleAlert];
[alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleDefault handler:nil]];

alert.shouldDismissBlock = ^ BOOL(SDCAlertAction *action) {
	return NO;
};

[alert presentWithCompletion:nil];
```

### Styling and Appearance

`SDCAlertController` is a normal view controller, so applying a `tintColor` to its `view` will color the buttons and any subviews you add to the `contentView`. If you are looking for more customizations, create a class that conforms to the `SDCAlertControllerVisualStyle` protocol and set it as the `visualStyle` on an `SDCAlertController` instance. You can also subclass `SDCAlertControllerDefaultVisualStyle` for a set of default values that you can then override as needed.

If you're feeling particularly adventurous, you can use a different transition/animation by creating a class that conforms to `UIViewControllerTransitioningDelegate` and setting it as the alert's `transitionCoordinator`. Transitioning is implemented using default iOS 8 custom view controller transitions, so anything you can do with a normal view controller, you can do with an alert controller.

## Backwards compatibility

`SDCAlertController` will in most cases be backwards compatible with `SDCAlertView`. However, most is not all, and if you need to fine-tune an alert just for iOS 7, you can still do that:

```objc
SDCAlertController *alert = [SDCAlertController alertWithTitle:@"Title" message:@"Message" preferredStyle:SDCAlertControllerStyleAlert];
// ... configure alert with content view, text fields, buttons, etc ...

if (alert.legacyAlertView) {
	// ... use alert.legacyAlertView to make iOS 7 modifications
} else {
	// Keep using original alert
}

[alert presentWithCompletion:nil];
```

## Behavior different from `UIAlertController`

With the introduction of `SDCAlertController`, pretty much all behavior in alerts could be replicated. If you use the legacy `SDCAlertView`, you may run into some additional problems as described below:

- Special interaction with the system. The system does not consider instances of `SDCAlertController` actual alerts, which means that won't experience the normal system interaction you'd expect from a normal alert. This also means that combining `UIAlertView` with `SDCAlertView` (or `SDCAlertController`) is a **bad idea**.
- **`SDCAlertView` only:** `UITextField` placeholders in different languages. "Login" and "Password" are entered as localized strings, but they aren't actually translated.
- **`SDCAlertView` only:** Some behavior is purposely not ported from `UIAlertView`. These cases are discussed in SDCAlertView.h.

## New in 2.0

**What's New:**
- All new API that matches and extends `UIAlertController`
- Ability to always show buttons horizontally or vertically
- Backwards compatible with `SDCAlertView` (1.0)
- More stylistic elements you can style (alert width, button separators, text fields, etc.)

## Support
I'm pretty active on [Stack Overflow](http://stackoverflow.com/users/751268/scott-berrevoets), so please use that if you have any questions. You can also use [Twitter](http://twitter.com/ScottBerrevoets) to contact me directly.

If you are experiencing bugs, feel free to post an issue or submit a pull request. I don't bite, promise!

## Credits
Some credits are in order:

- Robert Böhnke ([@robb](https://github.com/robb)): [RBBAnimation](https://github.com/robb/RBBAnimation)
- Lee McDermott ([@lmcd](https://github.com/lmcd)) for reverse-engineering the showing and dismissing animations.

And everyone else who contributed by reporting issues, creating pull requests, or in some other way!