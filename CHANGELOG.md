# CHANGELOG

### 11.1.2
**Bug Fixes:**
- Fix incorrect padding for content views in action sheets

### 11.1.1
**What's New:**
- Refactored the action sheet UI to code, eliminating the hard-to-understand XIB

## 11.1
**What's New:**
- Action sheets can now receive an image view on the left and accessory view on the right of each action
- The color of the chrome/dimming view can now be set on visual styles
- The spacing between title/message labels has been updated to the ones
  `UIAlertController` uses
  

**Bug Fixes:**
- View controllers presented from alerts/action sheets aren't dismissed
  anymore when using the alert's `dismiss()` method
- The area around text fields is now the same background color as alerts when one is set
- Dark mode appearances are more like the native `UIAlertController` ones

## 11.0
**What's New:**
- Dark Mode support on iOS 13.

## 10.0
This release brings Swift 5.0 compatibility.

### 9.0.1
**Bug Fixes:**
- Fixes incorrect margins for new iPhones

## 9.0
This release brings Swift 4.2 compatibility.

### 8.1.1
**Bug Fixes:**
- Fixes incorrect spacing when an action sheet doesn't have a label

## 8.1
This release brings Swift 4.1 compatibility.

**Bug Fixes:**
- Fixes build issues when using the new build system and CocoaPods
- Fixes a missing `contentView` in action sheets

## 8.0.2
**Bug Fixes:**
- Fixes the inverted `dismissOnOutsideTap` behavior for alert views
- Hides action sheet labels when no title or subtitle are provided
- Fixes action sheet layout issues on iPhone X
- Invokes the `preferredAction` when the return key is hit on a hardware
  keyboard
- Return no `preferredAction` when the style of the alert is an action sheet

### 8.0.1
**Bug Fixes:**
- Fixes a layout issue when creating an alert with a custom content view

## 8.0

This release brings Swift 4 and iOS 11 compatibility. It also increases the
deployment target to iOS 9.0.

**What's New:**
- Adds a closure for handling taps in the outer (chrome) area of the alert
- Improves accessibility for alert actions
- `AlertController.add()` has been renamed to `AlertController.addAction()` for
  clarity
- The `AlertBehaviors` constants are now lowercased, following Swift 3
  conventions.

**Bug Fixes**:
- Fixes an issue that could lead the alert to be shown in an unsupported
  orientation

### 7.1.2
**Bug Fixes**:
- Fixes a bug that could incorrectly set cancel button attributes on action
  sheets

### 7.1.1
**Bug Fixes**:
- Fixes a retain cycle when adding text fields to the alert
- Properly makes the first text field the first responder when presenting an
  alert with text fields

## 7.1
**What's New:**
- Makes `AlertVisualStyle` subclassable again
- Adds support for custom background colors in action sheets
- Adds Taptic feedback when dragging between buttons on iPhone 7

**Bug Fixes:**
- The dismissal animation looks like the system one again
- Action sheets without an explicit cancel button won't show the inferred cancel
  button twice anymore
- Button labels size and truncate as expected now, instead of being cut off

### 7.0.1
**Bug Fixes:**
- Avoids an infinite loop/crash when using an action sheet without explicit
  cancel buttons

# 7.0
This is a compatibility update for Swift 3.

**Bug Fixes:**
- Correctly calls the cancel button's handler in action sheets

# 6.0
This is a compatibility update for Swift 2.3.

### 5.1.1
**Bug Fixes:**
- Gives action buttons the button trait for Voice Over

## 5.1
**Bug Fixes:**
- Fixes the inability to override visual style properties in a subclass of
  `DefaultVisualStyle`. The `VisualStyle` protocol has been removed and the
  conforming class been renamed to `AlertVisualStyle`. The old class name is
  still available, but marked as deprecated and will be removed in the future.

**What's New:**
- Makes an `AlertAction`'s `handler` public.

# 5.0
5.0 is a compatibility update so the project builds in Swift 2.2 and
doesn't generate warnings. It also changes the Objective-C names of the public
enums, which Swift now supports.

**Bug Fixes:**
- Prioritize `textColorForAction()` over the `tintColor` of an action
- Properly exposes `visualStyle` as a property on `SDCAlertController` in Objective-C
- Makes `actionLayout` a non-optional, allowing it to be exposed to Objective-C
- Exposes a public init method in `DefaultVisualStyle` so subclassers don't have to implement this separately
- Correctly shows buttons if an alert has scrollable content after rotation
- Fixes incorrect accessibility labels on buttons

## 4.0.1
**Bug Fixes:**
- Fixes incorrect fonts for text in alerts

## 4.0
**What's New:**
- Adds support for presenting action sheets
- Implements alert behaviors such as parallax and "tap outside to dismiss"
- Action highlight colors can be changed with custom visual styles

**Changes:** 
This version introduces other changes that are not compatible with
previous versions of `SDCAlertView`.
- The `automaticallyFocusFirstTextField` property is now implemented as an alert
  behavior
- In Objective-C, the presentation and dismissal methods are now named
  `presentAnimated:completion:` and `dismissAnimated:completion:` to follow
  Objective-C nomenclature more closely
- The title and message label fonts are removed from `VisualStyle`. To change
  the labels' fonts, please use `attributedTitle` and `attributedMessage` with
  `NSFontAttributeName` instead.
- `setShouldDismissHandler()` and `setVisualStyle()` are now properties named
  `shouldDismissHandler` and `visualStyle` respectively. Their functionality is
  unchanged.
- The convenience method `showWithTitle(_:message:actionTitle:customView:)` has
  been renamed to `alertWithTitle(_:message:actionTitle:customView:)` to provide
  more consistency with the action sheet's counterpart

### 3.1.1
**Bug Fixes:**
- Fixes a retain cycle
- Resolves an issue that would not correctly disable actions when needed

### 3.1
**What's New:**
- Adds an option to give the alert a different background color

**Bug Fixes:**
- Fixes a bug that would not apply appropriate padding to the labels

### 3.0.4
**Bug Fixes:**
- Fixes a crash on iOS 8 when adding text fields to the alert

### 3.0.3 
**Bug Fixes:**
- Resolves an issue that would never use the white status bar color if it was
  specified

### 3.0.2
**Bug Fixes:**
- Fixes a major issue that would simply not display an alert
- The example project now formally depends on the SDCAlertView target
- Added a missing docstring

### 3.0.1
**Bug Fixes:**
- Fixes an issue that would sometimes use the wrong scroll direction for actions
- Fixes the pod spec so it refers to the correct tag, not a branch
- Removes some unused (overridden) methods in the Objective-C bridging header

## 3.0

**What's New:**
- Completely rewritten in Swift
- Updated for iOS 9
- Deployment target increased to iOS 8

### 2.5.3

**Bug Fixes:**
- Xcode 7 bugs/warnings

### 2.5.2

**Bug Fixes:**
- Solves an accessibility-related incompatibility between `UIAlertController`
  and `SDCAlertController` (#105)

### 2.5.1

**Bug Fixes:**
- Fixes a bug that would show the wrong cancel button title in a legacy alert in
  some cases
- Fixes a retain cycle between `SDCAlertController` and `SDCAlertView`

### 2.5

**What's New:**
- You can now specify the text alignment of the message label (#101)

**Bug Fixes:**
- Fixes an infinite loop that occurred on some device configurations (#91)
- Fixes the wrong button handler being called in some cases on iOS 7 (#97)

### 2.4.2

**What's New:**
- Re-introduces an explicit `title` property without generating warnings (#99)

### 2.4.1

**Bug Fixes:**
- Fixes a crash in a compatibility update introduced in the previous version

### 2.4

**Bug Fixes:**
- Fixes an issue that would prevent legacy alerts from calling the
  `shouldDismissHandler` (#90)

**What's New:**
- Adds 2 new customizable properties: `titleLabelColor` and `messageLabelColor`
  (#92)

### 2.3.2

**Bug Fixes:**
- Reverted the fix for ###87 because it causes a more prominent bug (#89)

### 2.3.1

**Bug Fixes:**
- Fixes crash when using attributed title in legacy alert (#85 & #86)
- Fixes a stack overflow on iPad 2 (#87)
- Fixes an issue that would not reflect the attributed of an attributed string
  after creating an alert (#88)

### 2.3.0

**What's New:**
- Improved semantics for alert action styles. See the discussion in #81 for more
  information.

**Bug Fixes:**
- Fixes an animation issue in `SDCAlertView` on iOS 7 (#79)
- The warning introduced in 2.2 is removed

### 2.2.0

**Bug Fixes:**
- Fixes an incompatibility issue that would not correctly fetch text fields on
  iOS 7 (#67)

### 2.1.1

**Bug Fixes:**
- Fixes an off-by-one error that breaks compatibility with iOS 7 (#70)

### 2.1

**What's New:**
- The `usesLegacyAlert` property is now made public

**Bug Fixes:**
- Updates the import in SDCAlertController.h to not depend on any precompiled
  headers
- Fixes several issues with the legacy alert (#62, #63, #64, #68)
- Improves upon `UIAlertController` so that when an alert button is quickly
  tapped, it will highlight (`UIAlertController` does not do this)
- Fixes Auto Layout warnings for multi-line labels (#60)
- Returns the correct text when accessing `titleLabel.text`

### 2.0.1

**Bug Fixes:**
- Raises an exception when presenting SDCAlertView 1.0 from a `UIAlertView` or
  `UIActionSheet` (#56)
- Prevents a crash when creating an alert with a `nil` title or message

## 2.0

**What's New:**
- All new API that matches and extends `UIAlertController`
- Ability to always show buttons horizontally or vertically
- Backwards compatible with `SDCAlertView` (1.0)
- More stylistic elements you can style (alert width, button separators, text
  fields, etc.)

### 1.4.3

**Bug Fixes:**
- Fixes an issue that would not enforce `contentPadding` on the title and
  message labels properly (#58)

### 1.4.2

**What's New:**
- Extra properties to specify padding and spacing in the alert (#55)

### 1.4.1

**Bug Fixes:**
- Show the button top separator in an alert without title or message text (#40)
- Initialization is written a little differently to be more subclass-friendly
- Ready for use in iOS 8

Though the alert can still be used in iOS 8, keep in mind that the actual iOS 8
alert looks slightly different. The plan is to eventually have support for both,
but that's currently not the case.

### 1.4

**What's New:**
- Added the ability to position a two-button alert vertically as opposed to
  horizontally (#29)
- Added `attributedTitle` and `attributedMessage` properties (#30)

**Bug Fixes:**
- Auto-layout doesn't complain anymore when using `[[SDCAlertView alloc] init]`
- Fixes a bug that would not show correct button titles in certain alert
  configurations (#32)
- Instead of clipping button text, it now reduces the size of text on buttons
  appropriately (#33)

### 1.3

**What's New:**
- The `SDCAlertViewTransitioning` protocol allows users to customize alert
  transitions and behavior
- `SDCAlertView` now supports `tintColor` for buttons and `contentView`

**Bug Fixes:**
- Fixes an issue where the status bar style would not be preserved if it was set
  to `UIStatusBarStyleLightContent` (#26 & #27)
- Fixes a bug that causes the app to lock up due to a race condition (#28)
- Adding subviews to `contentView` won't have any animation-related side effects
  anymore (see #25)

### 1.2.1

**Bug Fixes:**
- Resolves an issue that could put an app in a bad state when transitioning to
  and from multiple alerts in rapid succession.

### 1.2

**What's New:**
- New convenience methods for showing alerts more easily
- The `SDCAlertViewWidth` constant is made public (#24)
- The `contentView` does not require vertical constraints anymore, though they
  can be used to size the `contentView` other than "hug its subviews" (#23)

**Bug Fixes:**
- Resolves an issue that would show the status bar if it was previously hidden
  (#21)
- Resolves an issue that would sometimes return the wrong button index when
  using `addButtonWithTitle:`
- Transitions between alerts flow more logically if you call several show or
  dismiss methods right after each other (#25)
- The `animated` argument in `dismissWithClickedButtonIndex:animated:` is
  honored again

### 1.1

**What's New:**
- Support for styling an alert. A number of properties have been exposed so that
  alerts can be easily given a different style. Styling all alerts in an app
  using `UIAppearance` is also supported.

**Bug Fixes:**
- The alert's background is no longer using the toolbar hack (#16 & #17)
- Accessing a text field before calling `show` does not cause a crash anymore
  (#14)
- The color of text on a button color did not match `UIAlertView`'s text color
  100%
- A disabled button will have its label's `enabled` property set to `NO`, which
  is also where it gets its gray color from
- A 1px hairline at the bottom of the right button in a two-button alert was
  removed

## 1.0

This release marks the first official release of SDCAlertView.

SDCAlertView's behavior should now match UIAlertView's. Any behavior that's
different from UIAlertView and is not documented as a "won't fix" or known bug
is considered a bug that needs to be solved.

## 0.9

Beta release
