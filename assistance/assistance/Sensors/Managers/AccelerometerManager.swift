//
//  AccelerometerManager.swift
//  Labels
//
//  Created by Nickolas Guendling on 14/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class AccelerometerManager: NSObject, SensorManager {
    
    let sensorType = "accelerometer"
    
    var sensorConfiguration = NSMutableDictionary()
    
    static let sharedManager = AccelerometerManager()
    
    let motionManager = CMMotionManager()
    let realm = try! Realm()
    
    override init() {
        super.init()

        initSensorManager()
        
        motionManager.accelerometerUpdateInterval = collectionInterval()
        
        if isActive() {
            start()
        }
    }
    
    func didStart() {
        if motionManager.accelerometerAvailable {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
                (accelerometerData, error) in
                
                if let accelerometerData = accelerometerData where self.isActive() {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("acc - ", NSDate())
                        _ = try? self.realm.write {
                            self.realm.add(Accelerometer(accelerometerData: accelerometerData))
                        }
                    })
                }
                dispatch_async(dispatch_get_main_queue(), {
                    DataSync().syncData()
                })
            }
        }
    }
    
    func didStop() {
        /*
        * We do not actually stop requesting accelerometer updates using
        * motionManager.stopAccelerometerUpdates() here because we use
        * the accelerometer update calls to sync all sensor data to the server.
        */
        
        realm.delete(realm.objects(Accelerometer))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(Accelerometer).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for accelerometer in data {
                self.realm.delete(accelerometer)
            }
        }
        
        if realm.objects(Accelerometer).count == 0 {
            didUpdate()
        }
    }
    
}
