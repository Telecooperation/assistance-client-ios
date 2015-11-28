//
//  AccelerometerManager.swift
//  Labels
//
//  Created by Nicko on 14/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class AccelerometerManager: NSObject, SensorManager {
    
    let sensorName = "accelerometer"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = AccelerometerManager()
    
    let motionManager = CMMotionManager()
    let realm = try! Realm()
    
    override init() {
        super.init()

        motionManager.accelerometerUpdateInterval = updateInterval
        
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
                        DataSync().syncData()
                    })
                }
            }
        }
    }
    
    func didStop() {
        // TODO: really stop?
        motionManager.stopAccelerometerUpdates()
        
        realm.delete(realm.objects(Accelerometer))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(Accelerometer).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for accelerometer in data {
                self.realm.delete(accelerometer)
            }
        }
        
        if realm.objects(Accelerometer).count < 50 {
            didUpload()
        }
    }
    
}
