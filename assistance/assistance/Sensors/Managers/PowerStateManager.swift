//
//  PowerStateManager.swift
//  Labels
//
//  Created by Nicko on 20/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

class PowerStateManager: NSObject, SensorManager {
    
    let sensorName = "powerstate"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = PowerStateManager()
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        if isActive() {
            start()
        }
    }
    
    func didStart() {
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "savePowerState", name: UIDeviceBatteryLevelDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "savePowerState", name: UIDeviceBatteryStateDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "savePowerState", name: NSProcessInfoPowerStateDidChangeNotification, object: nil)
        
        savePowerState()
    }
    
    func didStop() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        realm.delete(realm.objects(PowerState))
    }
    
    func savePowerState() {
        let batteryState = UIDevice.currentDevice().batteryState
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        
        let isCharging = batteryState == .Charging || batteryState == .Full
        let percent = batteryLevel
        
        var chargingState = ChargingState.None
        if batteryState == .Full {
            chargingState = .Full
        } else if batteryLevel > 0.2 {
            chargingState = .Okay
        } else if batteryLevel <= 0.2 && batteryLevel >= 0 {
            chargingState = .Low
        }
        
        let powerSaveMode = NSProcessInfo.processInfo().lowPowerModeEnabled
        
        dispatch_async(dispatch_get_main_queue(), {
            _ = try? self.realm.write {
                self.realm.add(PowerState(isCharging: isCharging, percent: percent, chargingState: chargingState, powerSaveMode: powerSaveMode))
            }
        })
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(PowerState).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for powerState in data {
                self.realm.delete(powerState)
            }
        }
        
        if realm.objects(PowerState).count < 50 {
            didUpload()
        }
    }
    
}
