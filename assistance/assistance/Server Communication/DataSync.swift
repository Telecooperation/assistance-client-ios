//
//  DataSync.swift
//  Labels
//
//  Created by Nicko on 04/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import RealmSwift
import Locksmith
import GCNetworkReachability

class DataSync {
    
    let baseURL = "http://130.83.163.146" // 130.83.163.146 & 130.83.163.115
    
    let realm = try! Realm()
    
    let sensorManagers: [SensorManager] = [AccelerometerManager.sharedManager,
                                            ConnectionManager.sharedManager,
                                            WifiConnectionManager.sharedManager,
                                            GyroscopeManager.sharedManager,
                                            MagneticFieldManager.sharedManager,
                                            MotionActivityManager.sharedManager,
                                            PositionManager.sharedManager,
                                            PowerStateManager.sharedManager,
                                            MobileConnectionManager.sharedManager]
    
    func syncData() {
        
        guard let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"), dictionary = Locksmith.loadDataForUserAccount(userEmail), token = dictionary["token"] as? String else {
            print("Sync failed: Not authenticated!")
            return
        }
        
        guard let device_id = NSUserDefaults.standardUserDefaults().objectForKey("device_id") else {
            print("Sync failed: No device_id found!")
            return
        }
        
        let timeSinceLastUpload = NSDate().timeIntervalSinceDate(PositionManager.sharedManager.lastUploadTime())
        let forceCellularUploadIntervall = 60 * 60 * 24 * 3.0 // three days
        
        let reachability = GCNetworkReachability.reachabilityForInternetConnection()
        
        guard reachability.currentReachabilityStatus() == GCNetworkReachabilityStatusWiFi || timeSinceLastUpload > forceCellularUploadIntervall else {
            print("Sync failed: Not connected to WiFi!")
            return
        }
        
        var sensorReadings = [AnyObject]()
        var sensorDataToSync = [String: [Sensor]]()
        
        for sensorManager in sensorManagers {
            if sensorManager.shouldUpload() {
                sensorDataToSync[sensorManager.sensorName] = sensorManager.sensorData()
                for sensorData in sensorDataToSync[sensorManager.sensorName]! {
                    sensorReadings.append(sensorData.dictionary())
                }
            }
        }
        
        guard sensorReadings.count > 0 else {
            return
        }
        
        let params: [String: AnyObject] = ["device_id": device_id, "sensorreadings": sensorReadings]
        
        ServerConnection().post("\(baseURL)/sensordata/upload", token: token, params: params) {
            (succeeded: Bool, message: String) -> () in

            if succeeded {
                
                dispatch_async(dispatch_get_main_queue(), {
                    for sensorManager in self.sensorManagers {
                        if let syncedSensorData = sensorDataToSync[sensorManager.sensorName] where syncedSensorData.count > 0 {
                            sensorManager.sensorDataDidUpload(syncedSensorData)
                        }
                    }
                })
                
            } else if message == "Unauthorized (401)" {
                
                if let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"),
                   let dictionary = Locksmith.loadDataForUserAccount(userEmail),
                   let password = dictionary["password"] as? String {
                
                    UserManagement().login(userEmail, password: password) {
                        (succeeded: Bool, message: String) -> () in
                        
                        if !succeeded {
                            print("login failed.")
                        } else {
                            _ = try? Locksmith.updateData(["password": password, "token": message], forUserAccount: userEmail)
                        }
                    }
                }
                
            }
        }
    }
    
}
