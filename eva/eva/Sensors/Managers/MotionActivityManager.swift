//
//  MotionActivityManager.swift
//  Labels
//
//  Created by Nicko on 14/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class MotionActivityManager: NSObject, SensorManager {
    
    let sensorName = "motionactivity"
    
    let uploadInterval = 60.0
    let updateInterval = 10.0
    
    let motionActivityManager = CMMotionActivityManager()
    
    static let sharedManager = MotionActivityManager()
    
    let realm = try! Realm()
    
    func didStop() {
        realm.delete(realm.objects(MotionActivity))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            if CMMotionActivityManager.isActivityAvailable() {
                self.motionActivityManager.queryActivityStartingFromDate(lastUpdateTime(), toDate: NSDate(), toQueue: NSOperationQueue()) {
                    (motionActivities, error) in
                    
                    if let motionActivities = motionActivities {
                        dispatch_async(dispatch_get_main_queue(),{
                            
                            var previousMotionActivity = CMMotionActivity()
                            for motionActivity in motionActivities {
                                if motionActivity != previousMotionActivity && (motionActivity.cycling || motionActivity.automotive || motionActivity.running || motionActivity.stationary || motionActivity.walking || motionActivity.unknown) {
                                    _ = try? self.realm.write {
                                        self.realm.add(MotionActivity(motionActivity: motionActivity))
                                    }
                                    previousMotionActivity = motionActivity
                                }
                            }
                        })
                    }
                }
                didUpdate()
            }
            
            return Array(realm.objects(MotionActivity).toArray().prefix(50))
        }

        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for motionActivity in data {
                self.realm.delete(motionActivity)
            }
        }
        
        if realm.objects(MotionActivity).count < 50 {
            didUpload()
        }
    }
}
