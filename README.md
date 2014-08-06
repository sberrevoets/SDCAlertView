#SDCAlertView

`SDCAlertView` doesn't just look like a system alert in terms of user interface elements, it is the result of completely reverse-engineering `UIAlertView`. View hierarchy, labels, buttons, animations, user interaction; everything has been looked at and incorporated as much as possible.

You can think of `SDCAlertView` as `UIAlertView` on steroids. It has added functionality such as a `contentView` property and block syntax, while still keeping the `UIAlertView` look.

![Animated GIF showing alert](http://sberrevoets.github.io/SDCAlertView/ProgressViewAlert.gif)

## Installation
The easiest way to install is, of course, by using CocoaPods. The name of the pod is `SDCAlertView`.

If you're not using CocoaPods, you need:

- SDCAlertView.{h,m}
- SDCAlertViewTransitioning.h
- SDCAlertViewCoordinator.{h,m}
- SDCAlertViewController.{h,m}
- SDCAlertViewContentView.{h,m}
- SDCAlertViewBackgroundView.{h,m}
- SDCIntrinsicallySizedView.{h,m}

The project also depends on [RBBAnimation](https://github.com/robb/RBBAnimation) and [SDCAutoLayout](https://github.com/Scott90/SDCAutoLayout). These dependencies are automatically handled for you if you use CocoaPods.

## Usage
`SDCAlertView` is for use in iOS 7 only. It will not work properly on iOS 6.1 or below. Using `SDCAlertView` is very simple: just import SDCAlertView.h and use it as you would `UIAlertView`.

### Basic

Showing a basic `SDCAlertView` alert looks just like showing a basic `UIAlertView` alert:
```objc
SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Title"
												  message:@"This is a message"
												 delegate:self
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:@"OK", nil];
[alert show];
```

Or you can use one of the convenience methods:
```objc
[SDCAlertView alertWithTitle:@"Title" message:@"This is a message" buttons:@[@"OK"]];
```

### Block syntax

Block syntax saves you from having to use a delegate:
```objc
SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Title"
												  message:@"This is a message"
												 delegate:nil
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:@"OK", nil];
[alert showWithDismissHandler:^(NSInteger buttonIndex) {
	NSLog(@"Tapped button: %@", @(buttonIndex));
}];
```

### `contentView`

Of course, you're not using `SDCAlertView`'s full potential unless you are using the `contentView`:
```objc
SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:@"Title"
												  message:@"This is a message"
												 delegate:self
										cancelButtonTitle:@"Cancel"
										otherButtonTitles:@"OK", nil];
		
UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
[spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
[spinner startAnimating];

[alert.contentView addSubview:spinner];
[spinner sdc_horizontallyCenterInSuperview];
[spinner sdc_verticallyCenterInSuperviewWithOffset:SDCAutoLayoutStandardSiblingDistance];
[alert show];
```

### Additional delegate methods

You can also use the `alertView:shouldDismissWithButtonIndex:` and `alertView:shouldDeselectButtonAtIndex:` to prevent an alert from dismissing:
```objc
- (void)showAlert {
	SDCAlertView *alert = [[SDCAlertView alloc] initWithTitle:title
													  message:message
													 delegate:self
											cancelButtonTitle:@"Cancel"
											otherButtonTitles:nil];
	[alert show];
}

- (BOOL)alertView:(SDCAlertView *)alertView shouldDismissWithButtonIndex:(NSInteger)buttonIndex {
	return NO;
}

- (BOOL)alertView:(SDCAlertView *)alertView shouldDeselectButtonAtIndex:(NSInteger)buttonIndex {
	return YES;
}
```
This will deselect the cancel button when it's tapped, but it won't actually dismiss the alert. Useful for password-like alerts that you don't want dismissed until the right password is entered.

### Styling and appearance

`SDCAlertView` uses the `tintColor` for buttons and any subviews you add to the `contentView`. If you are looking for more customizations, you can use `UIAppearance` to style alerts (per instance or all at once):
```objc
[[SDCAlertView appearance] setTitleLabelFont:[UIFont boldSystemFontOfSize:22]];
[[SDCAlertView appearance] setMessageLabelFont:[UIFont italicSystemFontOfSize:14]];
[[SDCAlertView appearance] setNormalButtonFont:[UIFont boldSystemFontOfSize:12]];
[[SDCAlertView appearance] setSuggestedButtonFont:[UIFont italicSystemFontOfSize:12]];
[[SDCAlertView appearance] setTextFieldFont:[UIFont italicSystemFontOfSize:12]];
[[SDCAlertView appearance] setButtonTextColor:[UIColor grayColor]]; // will always override the tintColor
[[SDCAlertView appearance] setTextFieldTextColor:[UIColor purpleColor]];
[[SDCAlertView appearance] setTitleLabelTextColor:[UIColor greenColor]];
[[SDCAlertView appearance] setMessageLabelTextColor:[UIColor yellowColor]];
```

If you're feeling particularly adventurous, `SDCAlertView` makes it very easy to customize the way alerts are presented and dismissed. Set the `transitionCoordinator` property to a custom class that conforms to `SDCAlertViewTransitioning`, and implement the three protocol methods. For more detailed instructions, see SDCAlertViewTransitioning.h.

## Behavior different from `UIAlertView`
Unfortunately, there are a few things that can't or won't be duplicated:

- Special interaction with the system. The system does not consider instances of `SDCAlertView` actual alerts, which means that, for example, the `alertViewCancel:` method from `SDCAlertViewDelegate` will never be called.
- `UITextField` placeholders in different languages. "Login" and "Password" are entered as localized strings, but they aren't actually translated.
- Some behavior is purposely not ported from `UIAlertView`. These cases are discussed in SDCAlertView.h.

## New in 1.4

**What's New:**
 - Added the ability to position a two-button alert vertically as opposed to horizontally
 - Added `attributedTitle` and `attributedMessage` properties

**Bug Fixes:**
 - Auto-layout doesn't complain anymore when using `[[SDCAlertView alloc] init]`
 - Fixes a bug that would not show correct button titles in certain alert configurations
 - Instead of clipping button text, it now reduces the size of text on buttons appropriately

## Support
I'm pretty active on [Stack Overflow](http://stackoverflow.com/users/751268/scott-berrevoets), so please use that if you have any questions. You can also use [Twitter](http://twitter.com/ScottBerrevoets) to contact me directly.

If you are experiencing bugs, feel free to post an issue or submit a pull request. I don't bite, promise!

## Credits
Some credits are in order:

- Robert Böhnke ([@robb](https://github.com/robb)): [RBBAnimation](https://github.com/robb/RBBAnimation)
- Lee McDermott ([@lmcd](https://github.com/lmcd)) for reverse-engineering the showing and dismissing animations.
- César Castillo ([@JagCesar](https://github.com/JagCesar)) for the great idea of using a `UIToolbar` for easy live blurring (used in earlier versions of SDCAlertView).

And everyone else who contributed by reporting issues, creating pull requests, or in some other way!