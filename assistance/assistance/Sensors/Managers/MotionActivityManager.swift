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

class MotionActivityManager: SensorManager {
    
    let motionActivityManager = CMMotionActivityManager()
    
    static let sharedManager = MotionActivityManager()
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        sensorType = "motionactivity"
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    override func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void) {
        self.motionActivityManager.queryActivityStartingFromDate(NSDate(), toDate: NSDate(), toQueue: NSOperationQueue()) {
            _, error in
            
            if let error = error where error.code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                self.denySystemAuthorization()
                
                let contactPermissionViewController = viewController.storyboard?.instantiateViewControllerWithIdentifier(String(ContactPermissionViewController)) as! ContactPermissionViewController
                viewController.presentViewController(contactPermissionViewController, animated: true, completion: nil)
                
                completed(granted: false, error: error)
            } else {
                self.grantAuthorization()
                completed(granted: true, error: error)
            }
        }
    }
    
    override func didStop() {
//        realm.delete(realm.objects(MotionActivity))
    }
    
    override func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            if CMMotionActivityManager.isActivityAvailable() {
                self.motionActivityManager.queryActivityStartingFromDate(lastUpdateTime(), toDate: NSDate(), toQueue: NSOperationQueue()) {
                    motionActivities, error in
                    
                    if let motionActivities = motionActivities {
                        dispatch_async(dispatch_get_main_queue(), {
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
    
    override func sensorDataDidUpdate(data: [Sensor]) {
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
