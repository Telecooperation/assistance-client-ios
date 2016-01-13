//
//  ConnectionManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 21/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift
import GCNetworkReachability

class ConnectionManager: NSObject, SensorManager {
    
    let sensorType = "connection"
    
    var sensorConfiguration = NSMutableDictionary()
    
    static let sharedManager = ConnectionManager()
    
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

            let isWifi = networkReachabilityStatus == GCNetworkReachabilityStatusWiFi
            let isMobile = networkReachabilityStatus == GCNetworkReachabilityStatusWWAN
            dispatch_async(dispatch_get_main_queue(), {
                _ = try? self.realm.write {
                    self.realm.add(Connection(isWifi: isWifi, isMobile: isMobile))
                }
            })
        }
    }
    
    func didStop() {
        GCNetworkReachability().stopMonitoringNetworkReachability()
        
        realm.delete(realm.objects(Connection))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(Connection).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for connection in data {
                self.realm.delete(connection)
            }
        }
        
        if realm.objects(Connection).count == 0 {
            didUpdate()
        }
    }
    
}

