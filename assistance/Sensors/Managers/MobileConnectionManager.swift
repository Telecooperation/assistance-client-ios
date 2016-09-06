//
//  MobileConnectionManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 27/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreTelephony

import RealmSwift
import GCNetworkReachability

class MobileConnectionManager: SensorManager {
    
    static let sharedManager = MobileConnectionManager()
    
    let reachability = GCNetworkReachability(hostName: "www.google.com")
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        sensorType = "mobileconnection"
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    override func didStart() {
        reachability.startMonitoringNetworkReachabilityWithHandler {
            networkReachabilityStatus in
            
            if networkReachabilityStatus == GCNetworkReachabilityStatusWWAN {
                if let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider {
                    dispatch_async(dispatch_get_main_queue(), {
                        _ = try? self.realm.write {
                            self.realm.add(MobileConnection(carrier: carrier))
                        }
                    })
                }
            }
        }
    }
    
    override func didStop() {
        GCNetworkReachability().stopMonitoringNetworkReachability()
        
//        realm.delete(realm.objects(MobileConnection))
    }
    
    override func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(MobileConnection).toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    override func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for mobileconnection in data {
                self.realm.delete(mobileconnection)
            }
        }
        
        if realm.objects(MobileConnection).count == 0 {
            didUpdate()
        }
    }
    
}

