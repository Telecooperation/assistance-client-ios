//
//  GyroscopeManager.swift
//  Labels
//
//  Created by Nickolas Guendling on 20/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class GyroscopeManager: SensorManager {
    
    static let sharedManager = GyroscopeManager()
    
    let motionManager = CMMotionManager()
    let realm = try! Realm()
    
    override init() {
        super.init()

        sensorType = "gyroscope"
        initSensorManager()
        
        motionManager.gyroUpdateInterval = collectionInterval()
        
        if isActive() {
            start()
        }
    }
    
    override func didStart() {
        if motionManager.gyroAvailable {
            motionManager.startGyroUpdatesToQueue(NSOperationQueue()) {
                (gyroData, error) in
                
                if let gyroData = gyroData where self.isActive() {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("gyro - ", NSDate())
                        _ = try? self.realm.write {
                            self.realm.add(Gyroscope(gyroData: gyroData))
                        }
                    })
                }
            }
        }
    }
    
    override func didStop() {
        motionManager.stopGyroUpdates()
        
//        realm.delete(realm.objects(Gyroscope))
    }
    
    override func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(Gyroscope).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    override func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for gyroscope in data {
                self.realm.delete(gyroscope)
            }
        }
        
        if realm.objects(Gyroscope).count == 0 {
            didUpdate()
        }
    }
    
}
