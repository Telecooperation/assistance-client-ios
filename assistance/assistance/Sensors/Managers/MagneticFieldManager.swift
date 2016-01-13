//
//  MagneticFieldManager.swift
//  Labels
//
//  Created by Nickolas Guendling on 20/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class MagneticFieldManager: NSObject, SensorManager {
    
    let sensorType = "magneticfield"
    
    var sensorConfiguration = NSMutableDictionary()
    
    static let sharedManager = MagneticFieldManager()
    
    let motionManager = CMMotionManager()
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        initSensorManager()
        
        motionManager.magnetometerUpdateInterval = collectionInterval()
        
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
        motionManager.stopMagnetometerUpdates()
        
        realm.delete(realm.objects(MagneticField))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(MagneticField).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for magneticField in data {
                self.realm.delete(magneticField)
            }
        }
        
        if realm.objects(MagneticField).count == 0 {
            didUpdate()
        }
    }
    
}
