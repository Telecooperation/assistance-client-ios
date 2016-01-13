//
//  WifiConnectionManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 27/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import SystemConfiguration.CaptiveNetwork

import RealmSwift
import GCNetworkReachability

class WifiConnectionManager: NSObject, SensorManager {
    
    let sensorType = "wificonnection"
    
    var sensorConfiguration = NSMutableDictionary()
    
    static let sharedManager = WifiConnectionManager()
    
    let reachability = GCNetworkReachability(hostName: "www.google.com")
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        initSensorManager()
        
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
        if isActive() && shouldUpdate() {
            return Array(realm.objects(WifiConnection).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for wificonnection in data {
                self.realm.delete(wificonnection)
            }
        }
        
        if realm.objects(WifiConnection).count == 0 {
            didUpdate()
        }
    }
    
}
