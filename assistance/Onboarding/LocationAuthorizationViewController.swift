//
//  LocationAuthorizationViewController.swift
//  Labels
//
//  Created by Nickolas Guendling on 18/08/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import CoreLocation

class LocationAuthorizationViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    @IBAction func requestPermission(sender: AnyObject) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
