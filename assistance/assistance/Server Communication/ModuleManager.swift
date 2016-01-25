//
//  ModuleManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 29/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

class ModuleManager {
    
    enum Error: ErrorType {
        case NotAuthenticated
        case DeviceIDNotFound
    }
    
    func availableModules(completed: (result: Result) -> Void) {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("UserToken") else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        ServerConnection().get("\(GlobalConfig.baseURL)/assistance/list", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func activatedModules(completed: (result: Result) -> Void) {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("UserToken") else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        ServerConnection().get("\(GlobalConfig.baseURL)/assistance/activations", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func activateModule(moduleID: String, completed: (result: Result) -> Void) {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("UserToken") else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        let params: [String: AnyObject] = ["module_id": moduleID]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/assistance/activate", token: token, params: params) {
            result in
            
            do {
                let _ = try result()
                
                self.configureSensorsForModuleWithID(moduleID)
            } catch { }
            
            completed(result: result)
        }
    }
    
    func deactivateModule(moduleID: String, completed: (result: Result) -> Void) {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("UserToken") else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        let params: [String: AnyObject] = ["module_id": moduleID]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/assistance/deactivate", token: token, params: params) {
            result in
            
            do {
                let _ = try result()
                
                self.deactivateSensorsForModuleWithID(moduleID)
            } catch { }
            
            completed(result: result)
        }
    }
    
    func currentInformation(completed: (result: Result) -> Void) {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("UserToken") else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let deviceID = defaults.stringForKey("device_id") else {
            completed(result: { throw Error.DeviceIDNotFound })
            return
        }
        
        ServerConnection().get("\(GlobalConfig.baseURL)/assistance/current/\(deviceID)", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func currentInformationForModule(moduleID: String, completed: (result: Result) -> Void) {
        guard let token = NSUserDefaults.standardUserDefaults().stringForKey("UserToken") else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let deviceID = defaults.stringForKey("device_id") else {
            completed(result: { throw Error.DeviceIDNotFound })
            return
        }
        
        ServerConnection().get("\(GlobalConfig.baseURL)/assistance/\(moduleID)/current/\(deviceID)", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func moduleWithID(moduleID: String) -> [String: AnyObject]? {
        if let archivedAvailableModules = NSUserDefaults.standardUserDefaults().objectForKey("availableModules") as? NSData,
            availableModules = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAvailableModules) as? [[String: AnyObject]] {
                
                return availableModules.filter({ ($0["id"] as! String) == moduleID }).first
        }
        
        return nil
    }
    
    func nameForModuleWithID(moduleID: String) -> String? {
        if let module = self.moduleWithID(moduleID) {
            return module["name"] as? String
        }
        
        return nil
    }
    
    func configureSensorsForModuleWithID(moduleID: String) {
        if let module = self.moduleWithID(moduleID) {
            let requiredSensors = module["requiredCapabilities"] as! [[String: AnyObject]]
            let optionalSensors = module["optionalCapabilites"] as! [[String: AnyObject]]
            let sensors = requiredSensors + optionalSensors
            for sensor in sensors {
                if let sensorManager = SensorsManager().sensorManagerForType(sensor["type"] as! String) {
                    sensorManager.startSensingForModuleWithID(moduleID, collectionInterval: sensor["collection_interval"] as! Double, updateInterval: sensor["update_interval"] as! Double)
                }
            }
        }
    }
    
    func deactivateSensorsForModuleWithID(moduleID: String) {
        if let module = self.moduleWithID(moduleID) {
            let requiredSensors = module["requiredCapabilities"] as! [[String: AnyObject]]
            let optionalSensors = module["optionalCapabilites"] as! [[String: AnyObject]]
            let sensors = requiredSensors + optionalSensors
            for sensor in sensors {
                if let sensorManager = SensorsManager().sensorManagerForType(sensor["type"] as! String) {
                    sensorManager.stopSensingForModuleWithID(moduleID)
                }
            }
        }
    }
    
    func resetModules() {
        if let path = NSBundle.mainBundle().pathForResource("Sensors", ofType: "plist"), sensorConfiguration = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            NSUserDefaults.standardUserDefaults().setObject(sensorConfiguration, forKey: "sensorConfiguration")
        }
        dispatch_async(dispatch_get_main_queue(), {
            _ = try? Realm().write {
                _ = try? Realm().deleteAll()
            }
        })
        activatedModules {
            result in
            
            do {
                let data = try result()
                if let dataString = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) where dataString.length > 0,
                    let modules = try? NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableLeaves) as? NSArray {
                        
                        let activatedModules = modules as! [String]
                        for moduleID in activatedModules {
                            self.deactivateModule(moduleID) { result in }
                        }
                }
            } catch { }
        }

    }
    
}
