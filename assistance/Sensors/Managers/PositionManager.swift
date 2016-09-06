//
//  PositionManager.swift
//  Labels
//
//  Created by Nickolas Guendling on 11/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreLocation
import RealmSwift

class PositionManager: SensorManager, CLLocationManagerDelegate {
    
    static let sharedManager = PositionManager()
    
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        sensorType = "position"
        initSensorManager()
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
        if isActive() {
            start()
        }
    }
    
    override func needsSystemAuthorization() -> Bool {
        return CLLocationManager.authorizationStatus() != .AuthorizedAlways
    }
    
    override func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void) {
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .AuthorizedAlways: self.grantAuthorization()
            case .Denied, .Restricted: self.denySystemAuthorization()
            default: ()
        }
    }
    
    override func didStart() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.startUpdatingLocation()
    }
    
    override func didStop() {
        /*
         * We do not actually stop requesting location updates using
         * locationManager.stopUpdatingLocation() here because this
         * would stop the other sensors from being updated in the
         * background!
         */
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
//        realm.delete(realm.objects(Position))
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("loc")
        if isActive() && shouldUpdate() {
            print("loc saved")
            _ = try? realm.write {
                self.realm.add(Position(location: locations.last!))
            }
            didUpdate()
        }
    }
    
    override func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(Position).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    override func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for position in data {
                self.realm.delete(position)
            }
        }
        
        if realm.objects(Position).count == 0 {
            didUpdate()
        }
    }
}
