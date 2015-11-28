//
//  PositionManager.swift
//  Labels
//
//  Created by Nicko on 11/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreLocation
import RealmSwift

class PositionManager: NSObject, SensorManager, CLLocationManagerDelegate {
    
    let sensorName = "position"
    
    let uploadInterval = 60.0 //TODO: update upload intervall!
    let updateInterval = 10.0
    
    static let sharedManager = PositionManager()
    
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
        if isActive() {
            start()
        }
    }
    
    func didStart() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func didStop() {
        /*
        * We do not actually stop requesting location updates using
        * locationManager.stopUpdatingLocation() here because this
        * would stop the other sensors from being updated in the
        * background!
        */
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        realm.delete(realm.objects(Position))
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
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(Position).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for position in data {
                self.realm.delete(position)
            }
        }
        
        if realm.objects(Position).count < 50 {
            didUpload()
        }
    }
}
