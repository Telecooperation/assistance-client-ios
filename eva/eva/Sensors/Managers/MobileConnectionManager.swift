//
//  MobileConnectionManager.swift
//  eva
//
//  Created by Nicko on 27/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreTelephony

import RealmSwift
import GCNetworkReachability

class MobileConnectionManager: NSObject, SensorManager {
    
    let sensorName = "mobileconnection"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = MobileConnectionManager()
    
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
            
            if networkReachabilityStatus == GCNetworkReachabilityStatusWWAN {
                if let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider, carrierName = carrier.carrierName, mobileCountryCode = carrier.mobileCountryCode, mobileNetworkCode = carrier.mobileNetworkCode {
                    dispatch_async(dispatch_get_main_queue(), {
                        _ = try? self.realm.write {
                            self.realm.add(MobileConnection(carrierName: carrierName, mobileCountryCode: mobileCountryCode, mobileNetworkCode: mobileNetworkCode, voipAvailable: carrier.allowsVOIP))
                        }
                    })
                }
            }
        }
    }
    
    func didStop() {
        GCNetworkReachability().stopMonitoringNetworkReachability()
        
        realm.delete(realm.objects(MobileConnection))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(MobileConnection).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for mobileconnection in data {
                self.realm.delete(mobileconnection)
            }
        }
        
        if realm.objects(MobileConnection).count < 50 {
            didUpload()
        }
    }
    
}

