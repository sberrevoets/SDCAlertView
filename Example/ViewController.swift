//
//  ViewController.swift
//  Example
//
//  Created by Scott Berrevoets on 10/4/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit
import SDCAlertView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let alertController = AlertController(title: "Title", message: "Message")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

