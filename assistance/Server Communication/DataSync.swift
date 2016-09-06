//
//  DataSync.swift
//  Labels
//
//  Created by Nickolas Guendling on 04/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import RealmSwift
import GCNetworkReachability

class DataSync {
    
    let realm = try! Realm()
    
    let sensorManagers = SensorsManager().allSensorManagers()
    
    func syncData() {
        
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("UserToken") else {
            print("Sync failed: Token not found!")
            return
        }
        
        guard let device_id = NSUserDefaults.standardUserDefaults().objectForKey("device_id") else {
            print("Sync failed: No device_id found!")
            return
        }
        
        let reachability = GCNetworkReachability.reachabilityForInternetConnection()
        
        var sensorReadings = [AnyObject]()
        var sensorDataToSync = [String: [Sensor]]()
        
        for sensorManager in sensorManagers {
            if sensorManager.isActive() && sensorManager.shouldUpdate() || reachability.currentReachabilityStatus() == GCNetworkReachabilityStatusWiFi {
                sensorDataToSync[sensorManager.sensorType] = sensorManager.sensorData()
                for sensorData in sensorDataToSync[sensorManager.sensorType]! {
                    sensorReadings.append(sensorData.dictionary())
                }
            }
        }
        
        guard sensorReadings.count > 0 else {
            return
        }
        
        let params: [String: AnyObject] = ["device_id": device_id, "sensorreadings": sensorReadings]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/sensordata/upload", token: token, params: params) {
            result in
            
            do {
                let _ = try result()
                
                dispatch_async(dispatch_get_main_queue(), {
                    for sensorManager in self.sensorManagers {
                        if let syncedSensorData = sensorDataToSync[sensorManager.sensorType] where syncedSensorData.count > 0 {
                            sensorManager.sensorDataDidUpdate(syncedSensorData)
                        }
                    }
                })
                
            } catch ServerConnection.Error.Unauthorized {

                if let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"),
                    let password = NSUserDefaults.standardUserDefaults().stringForKey("UserPassword") {
                        
                        UserManager().login(userEmail, password: password) {
                            result in
                            
                            do {
                                let data = try result()
                                
                                if let dataString = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) where dataString.length > 0,
                                    let dataJSON = try? NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableLeaves) as! NSDictionary,
                                    token = dataJSON["token"] as? String {
                                        NSUserDefaults.standardUserDefaults().setObject(password, forKey: "UserPassword")
                                        NSUserDefaults.standardUserDefaults().setObject(token, forKey: "UserToken")
                                }
                            } catch {
                                print("login failed.")
                            }
                        }
                }
            
            } catch {  }

        }
    }
    
}
