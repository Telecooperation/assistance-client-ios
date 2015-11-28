//
//  GyroscopeManager.swift
//  Labels
//
//  Created by Nicko on 20/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class GyroscopeManager: NSObject, SensorManager {
    
    let sensorName = "gyroscope"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = GyroscopeManager()
    
    let motionManager = CMMotionManager()
    let realm = try! Realm()
    
    override init() {
        super.init()

        motionManager.gyroUpdateInterval = updateInterval
        
        if isActive() {
            start()
        }
    }
    
    func didStart() {
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
    
    func didStop() {
        // TODO: really stop?
        motionManager.stopGyroUpdates()
        
        realm.delete(realm.objects(Gyroscope))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(Gyroscope).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for gyroscope in data {
                self.realm.delete(gyroscope)
            }
        }
        
        if realm.objects(Gyroscope).count < 50 {
            didUpload()
        }
    }
    
}
