//
//  LocationAuthorizationFailedViewController.swift
//  Labels
//
//  Created by Nicko on 18/08/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import CoreLocation

class LocationAuthorizationFailedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        dismissIfAuthorized()
    }
    
    func applicationWillEnterForeground() {
        dismissIfAuthorized()
    }
    
    func dismissIfAuthorized() {
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
