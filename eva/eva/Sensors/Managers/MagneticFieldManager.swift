//
//  MagneticFieldManager.swift
//  Labels
//
//  Created by Nicko on 20/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class MagneticFieldManager: NSObject, SensorManager {
    
    let sensorName = "magneticfield"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = MagneticFieldManager()
    
    let motionManager = CMMotionManager()
    let realm = try! Realm()
    
    override init() {
        super.init()

        motionManager.magnetometerUpdateInterval = updateInterval
        
        if isActive() {
            start()
        }
    }
    
    func didStart() {
        if motionManager.magnetometerAvailable {
            motionManager.startMagnetometerUpdatesToQueue(NSOperationQueue()) {
                (magnetometerData, error) in
                
                if let magnetometerData = magnetometerData where self.isActive() {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("mag - ", NSDate())
                        _ = try? self.realm.write {
                            self.realm.add(MagneticField(magnetometerData: magnetometerData))
                        }
                    })
                }
            }
        }
    }
    
    func didStop() {
        // TODO: really stop?
        motionManager.stopMagnetometerUpdates()
        
        realm.delete(realm.objects(MagneticField))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(MagneticField).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for magneticfield in data {
                self.realm.delete(magneticfield)
            }
        }
        
        if realm.objects(MagneticField).count < 50 {
            didUpload()
        }
    }
    
}
