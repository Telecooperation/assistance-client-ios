//
//  TucanSensorManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

class TucanManager: NSObject, SensorManager {

    let sensorType = "tucancredentials"
    
    var sensorConfiguration = NSMutableDictionary()
    
    static let sharedManager = TucanManager()
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    func needsAuthorization() -> Bool {
        return true
    }
    
    func requestAuthorizationFromViewController(viewController: UIViewController) {
        let tucanLoginViewController = viewController.storyboard?.instantiateViewControllerWithIdentifier("TucanLogin") as! TucanLoginTableViewController
        viewController.presentViewController(tucanLoginViewController, animated: true, completion: nil)
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(Tucan).filter("isNew == true").toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for tucan in data {
                tucan.setSynced()
            }
        }
        
        if realm.objects(Tucan).count == 0 {
            didUpdate()
        }
    }
    
}
