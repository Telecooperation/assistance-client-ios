//
//  ViewController.swift
//  assistance
//
//  Created by Nicko on 08/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            performSegueWithIdentifier("locationAuthorizationSegue", sender: self)
        } else if CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted {
            performSegueWithIdentifier("locationAuthorizationFailedSegue", sender: self)
        } else if let _ = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail") {
            DataSync().syncData()
        } else {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

}
