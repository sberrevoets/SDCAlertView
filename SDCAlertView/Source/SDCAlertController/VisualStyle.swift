//
//  VisualStyle.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 8/22/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

public protocol VisualStyle {

    var width: CGFloat { get }
    var cornerRadius: CGFloat { get }
    var contentPadding: UIEdgeInsets { get }

    var margins: UIEdgeInsets { get }
    var parallax: UIOffset { get }

    var titleLabelFont: UIFont { get }
    var messageLabelFont: UIFont { get }

    var verticalElementSpacing: CGFloat { get }

    var actionViewSize: CGSize { get }
    var actionViewSeparatorColor: UIColor { get }
    var actionViewSeparatorThickness: CGFloat { get }

    func textColor(forAction action: AlertAction?) -> UIColor
    func font(forAction action: AlertAction?) -> UIFont

    var textFieldFont: UIFont { get }
    var textFieldHeight: CGFloat { get }
    var textFieldBorderColor: UIColor { get }
    var textFieldMargins: UIEdgeInsets { get }
}

extension VisualStyle {

    public var width: CGFloat { return 270 }
    public var cornerRadius: CGFloat { return 13 }
    public var contentPadding: UIEdgeInsets { return UIEdgeInsets(top: 36, left: 16, bottom: 12, right: 16) }

    public var margins: UIEdgeInsets { return UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0) }
    public var parallax: UIOffset { return UIOffset(horizontal: 15.75, vertical: 15.75) }

    public var titleLabelFont: UIFont { return UIFont.boldSystemFontOfSize(17) }
    public var messageLabelFont: UIFont { return UIFont.systemFontOfSize(13) }

    public var verticalElementSpacing: CGFloat { return 24 }

    public var actionViewSize: CGSize { return CGSize(width: 90, height: 44) }
    public var actionViewSeparatorColor: UIColor { return UIColor(white: 0.5, alpha: 0.5) }
    public var actionViewSeparatorThickness: CGFloat { return 1 / UIScreen.mainScreen().scale }

    public func textColor(forAction action: AlertAction?) -> UIColor {
        if action?.style == .Destructive {
            return UIColor.redColor()
        } else {
            return UIView().tintColor
        }
    }

    public func font(forAction action: AlertAction?) -> UIFont {
        if action?.style == .Preferred {
            return UIFont.boldSystemFontOfSize(17)
        } else {
            return UIFont.systemFontOfSize(17)
        }
    }

    public var textFieldFont: UIFont { return UIFont.systemFontOfSize(13) }
    public var textFieldHeight: CGFloat { return 25 }
    public var textFieldBorderColor: UIColor {
        return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
    }
    public var textFieldMargins: UIEdgeInsets { return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) }
}

public struct DefaultVisualStyle: VisualStyle { }
