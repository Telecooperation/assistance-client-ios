//
//  ConnectionManager.swift
//  assistance
//
//  Created by Nicko on 21/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift
import GCNetworkReachability

class ConnectionManager: NSObject, SensorManager {
    
    let sensorName = "connection"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = ConnectionManager()
    
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
        if isActive() && shouldUpload() {
            return Array(realm.objects(Connection).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for connection in data {
                self.realm.delete(connection)
            }
        }
        
        if realm.objects(Connection).count < 50 {
            didUpload()
        }
    }
    
}

