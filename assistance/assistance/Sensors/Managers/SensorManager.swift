//
//  SensorManager.swift
//  Labels
//
//  Created by Nickolas Guendling on 11/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

@objc protocol SensorManager {
    
    var sensorType: String { get }
    
    var sensorConfiguration: NSMutableDictionary { get set }
    
    func sensorData() -> [Sensor]
    func sensorDataDidUpdate(data: [Sensor])
    
    optional func needsSystemAuthorization() -> Bool
    optional func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void)
    
    optional func didStart()
    optional func didStop()
}

extension SensorManager {
    
    func initSensorManager() {
        if let sensorConfigurations = NSUserDefaults.standardUserDefaults().objectForKey("sensorConfiguration")?.mutableCopy() as? NSMutableDictionary, sensorConfiguration = sensorConfigurations[sensorType] {
            self.sensorConfiguration = sensorConfiguration.mutableCopy() as! NSMutableDictionary
        }
    }
    
    func name() -> String {
        if let name = sensorConfiguration["name"] as? String {
            return name
        }
        
        return ""
    }
    
    func needsUserAuthorization() -> Bool {
        if let authorizationStatusNumber = sensorConfiguration["authorization_status"] as? NSNumber,
            authorizationStatus = SensorAuthorizationStatus(rawValue: Int(authorizationStatusNumber.intValue))
            where authorizationStatus == .Granted {
            
            return false
        }
        
        return true
    }
    
    func needsSystemAuthorization() -> Bool {
        if let authorizationStatusNumber = sensorConfiguration["authorization_status"] as? NSNumber,
            authorizationStatus = SensorAuthorizationStatus(rawValue: Int(authorizationStatusNumber.intValue))
            where authorizationStatus == .NeedsSystemAuthorization || authorizationStatus == .SystemAuthorizationDenied {
                
                return true
        }
        
        return false
    }
    
    func needsAuthorization() -> Bool {
        return needsUserAuthorization() || needsSystemAuthorization()
    }
    
    func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void) {
        grantAuthorization()
        
        completed(granted: true, error: nil)
    }
    
    func grantAuthorization() {
        sensorConfiguration["authorization_status"] = NSNumber(integer: SensorAuthorizationStatus.Granted.rawValue)
        saveSensorConfiguration()
    }
    
    func denyAuthorization() {
        sensorConfiguration["authorization_status"] = NSNumber(integer: SensorAuthorizationStatus.Denied.rawValue)
        saveSensorConfiguration()
    }
    
    func denySystemAuthorization() {
        sensorConfiguration["authorization_status"] = NSNumber(integer: SensorAuthorizationStatus.SystemAuthorizationDenied.rawValue)
        saveSensorConfiguration()
    }
    
    func startSensingForModuleWithID(moduleId: String, collectionInterval: Double, updateInterval: Double) {
        if !(sensorConfiguration["used_by_modules"] as! [String]).contains(moduleId) {
            (sensorConfiguration["used_by_modules"] as! NSMutableArray).addObject(moduleId)
            (sensorConfiguration["collection_interval"] as! NSMutableArray).addObject(collectionInterval)
            (sensorConfiguration["update_interval"] as! NSMutableArray).addObject(updateInterval)
            
            saveSensorConfiguration()
            
            if (sensorConfiguration["used_by_modules"] as! [String]).count == 1 {
                start()
            }
        }
    }
    
    func stopSensingForModuleWithID(moduleId: String, collectionInterval: Double, updateInterval: Double) {
        if let index = (sensorConfiguration["used_by_modules"] as! [String]).indexOf(moduleId) {
            (sensorConfiguration["used_by_modules"] as! NSMutableArray).removeObjectAtIndex(index)
            (sensorConfiguration["collection_interval"] as! NSMutableArray).removeObjectAtIndex(index)
            (sensorConfiguration["update_interval"] as! NSMutableArray).removeObjectAtIndex(index)
            
            saveSensorConfiguration()
            
            if (sensorConfiguration["used_by_modules"] as! [String]).count == 0 {
                stop()
            }
        }
    }
    
    func start() {
        didStart?()
    }
    
    func stop() {
        didStop?()
    }
    
    func isActive() -> Bool {
        return (sensorConfiguration["used_by_modules"] as! NSArray).count > 0
    }
    
    func isRealtime() -> Bool {
        return (sensorConfiguration["update_interval"] as! [Double]).filter({ $0 >= 0 }).count > 0
    }
    
    func updateInterval() -> Double {
        return ((sensorConfiguration["update_interval"] as! [Double]).filter({ $0 >= 0 }) + [60.0 * 60.0 * 24.0]).minElement()!
    }
    
    func shouldUpdate() -> Bool {
        return NSDate().timeIntervalSinceDate(lastUpdateTime()) >= updateInterval()
    }
    
    func lastUpdateTime() -> NSDate {
        return sensorConfiguration["last_update"] as! NSDate
    }
    
    func didUpdate() {
        sensorConfiguration["last_update"] = NSDate()
        saveSensorConfiguration()
    }
    
    func collectionInterval() -> Double {
        return ((sensorConfiguration["collection_interval"] as! [Double]).filter({ $0 >= 0 }) + [60.0 * 60.0 * 24.0]).minElement()!
    }
    
    func shouldCollect() -> Bool {
        return NSDate().timeIntervalSinceDate(lastCollectionTime()) >= collectionInterval()
    }
    
    func lastCollectionTime() -> NSDate {
        return sensorConfiguration["last_collection"] as! NSDate
    }
    
    func didCollect() {
        sensorConfiguration["last_collection"] = NSDate()
        saveSensorConfiguration()
    }
    
    func saveSensorConfiguration() {
        if let sensorConfigurations = NSUserDefaults.standardUserDefaults().objectForKey("sensorConfiguration")?.mutableCopy() as? NSMutableDictionary {
            sensorConfigurations[sensorType] = self.sensorConfiguration
            NSUserDefaults.standardUserDefaults().setObject(sensorConfigurations, forKey: "sensorConfiguration")
        }
    }
}
