//
//  AlertAction.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/12/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

@objc
public enum AlertActionStyle: Int {
    case Default
    case Preferred
    case Destructive
}

@objc(SDCAlertAction)
public class AlertAction: NSObject {

    public convenience init(title: String?, style: AlertActionStyle,
        handler: ((AlertAction) -> Void)? = nil)
    {
        self.init()
        self.title = title
        self.style = style
        self.handler = handler
    }

    var handler: (AlertAction -> Void)?

    private(set) public var title: String?
    private(set) public var style: AlertActionStyle = .Default

    public var enabled = true
}
