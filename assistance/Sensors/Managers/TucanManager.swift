//
//  TucanSensorManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

class TucanManager: SensorManager {

    static let sharedManager = TucanManager()
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        sensorType = "tucancredentials"
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    override func needsSystemAuthorization() -> Bool {
        return realm.objects(Tucan).count == 0
    }
    
    override func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void) {
        let tucanLoginViewController = viewController.storyboard?.instantiateViewControllerWithIdentifier("TucanLogin") as! UINavigationController
        viewController.presentViewController(tucanLoginViewController, animated: true, completion: nil)
    }
    
    override func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(Tucan).filter("isNew == true").toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    override func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for tucan in data {
                tucan.setSynced()
            }
        }
        
        if realm.objects(Tucan).filter("isNew == true").count == 0 {
            didUpdate()
        }
    }
    
}
