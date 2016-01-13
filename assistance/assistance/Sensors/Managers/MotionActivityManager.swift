//
//  MotionActivityManager.swift
//  Labels
//
//  Created by Nickolas Guendling on 14/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion
import RealmSwift

class MotionActivityManager: NSObject, SensorManager {
    
    let sensorType = "motionactivity"
    
    var sensorConfiguration = NSMutableDictionary()
    
    let motionActivityManager = CMMotionActivityManager()
    
    static let sharedManager = MotionActivityManager()
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void) {
        self.motionActivityManager.queryActivityStartingFromDate(NSDate(), toDate: NSDate(), toQueue: NSOperationQueue()) {
            _, error in
            
            if let error = error where error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                self.denySystemAuthorization()
                completed(granted: false, error: error)
            } else {
                self.grantAuthorization()
                completed(granted: true, error: error)
            }
        }
    }
    
    func didStop() {
        realm.delete(realm.objects(MotionActivity))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            if CMMotionActivityManager.isActivityAvailable() {
                self.motionActivityManager.queryActivityStartingFromDate(lastUpdateTime(), toDate: NSDate(), toQueue: NSOperationQueue()) {
                    motionActivities, error in
                    
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
            
            return Array(realm.objects(MotionActivity).toArray().prefix(20))
        }

        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for motionActivity in data {
                self.realm.delete(motionActivity)
            }
        }
        
        if realm.objects(MotionActivity).count == 0 {
            didUpdate()
        }
    }
}
