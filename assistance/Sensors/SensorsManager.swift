//
//  SensorsManager.swift
//  assistance
//
//  Created by Nicko on 13/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class SensorsManager {
    
    let sensorManagers: [String: SensorManager] = ["accelerometer": AccelerometerManager.sharedManager,
                                                    "calendar": CalendarManager.sharedManager,
                                                    "connection": ConnectionManager.sharedManager,
                                                    "contact": ContactManager.sharedManager,
                                                    "facebooktoken": FacebookManager.sharedManager,
                                                    "gyroscope": GyroscopeManager.sharedManager,
                                                    "magneticfield": MagneticFieldManager.sharedManager,
                                                    "mobileconnection": MobileConnectionManager.sharedManager,
                                                    "motionactivity": MotionActivityManager.sharedManager,
                                                    "position": PositionManager.sharedManager,
                                                    "powerlevel": PowerLevelManager.sharedManager,
                                                    "powerstate": PowerStateManager.sharedManager,
                                                    "tucancredentials": TucanManager.sharedManager,
                                                    "wificonnection": WifiConnectionManager.sharedManager]
    
    func allSensorTypes() -> [String] {
        return sensorManagers.map({ $0.0 }).sort { $0 < $1 }
    }
    
    func allSensorManagers() -> [SensorManager] {
        return sensorManagers.map { $0.1 }
    }
    
    func sensorManagerForType(type: String) -> SensorManager? {
        return sensorManagers[type]
    }

}