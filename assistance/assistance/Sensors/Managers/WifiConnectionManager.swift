//
//  WifiConnectionManager.swift
//  assistance
//
//  Created by Nicko on 27/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import SystemConfiguration.CaptiveNetwork

import RealmSwift
import GCNetworkReachability

class WifiConnectionManager: NSObject, SensorManager {
    
    let sensorName = "wificonnection"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = WifiConnectionManager()
    
    let reachability = GCNetworkReachability(hostName: "www.google.com")
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        if isActive() {
            start()
        }
    }
    
    func didStart() {
        reachability.startMonitoringNetworkReachabilityWithHandler {
            networkReachabilityStatus in
            
            if networkReachabilityStatus == GCNetworkReachabilityStatusWiFi {
                var ssid = ""
                var bssid = ""
                
                let interfaces:CFArray! = CNCopySupportedInterfaces()
                for i in 0..<CFArrayGetCount(interfaces){
                    let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, i)
                    let rec = unsafeBitCast(interfaceName, AnyObject.self)
                    let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
                    if unsafeInterfaceData != nil {
                        let interfaceData = unsafeInterfaceData! as Dictionary!
                        ssid = interfaceData["SSID"] as! String
                        bssid = interfaceData["BSSID"] as! String
                    }
                }
                
                if ssid != "" && bssid != "" {
                    dispatch_async(dispatch_get_main_queue(), {
                        _ = try? self.realm.write {
                            self.realm.add(WifiConnection(ssid: ssid, bssid: bssid))
                        }
                    })
                }
            }
        }
    }
    
    func didStop() {
        GCNetworkReachability().stopMonitoringNetworkReachability()
        
        realm.delete(realm.objects(WifiConnection))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(WifiConnection).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for wificonnection in data {
                self.realm.delete(wificonnection)
            }
        }
        
        if realm.objects(WifiConnection).count < 50 {
            didUpload()
        }
    }
    
}
