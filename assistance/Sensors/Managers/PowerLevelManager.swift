//
//  PowerLevel.swift
//  assistance
//
//  Created by Nickolas Guendling on 09/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

class PowerLevelManager: SensorManager {
    
    static let sharedManager = PowerLevelManager()
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        sensorType = "powerlevel"
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    override func didStart() {
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "savePowerLevel", name: UIDeviceBatteryLevelDidChangeNotification, object: nil)
        
        savePowerLevel()
    }
    
    override func didStop() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
//        realm.delete(realm.objects(PowerLevel))
    }
    
    func savePowerLevel() {
        let percent = UIDevice.currentDevice().batteryLevel
        
        dispatch_async(dispatch_get_main_queue(), {
            _ = try? self.realm.write {
                self.realm.add(PowerLevel(percent: percent))
            }
        })
    }
    
    override func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(PowerLevel).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    override func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for powerLevel in data {
                self.realm.delete(powerLevel)
            }
        }
        
        if realm.objects(PowerLevel).count == 0 {
            didUpdate()
        }
    }
    
}
