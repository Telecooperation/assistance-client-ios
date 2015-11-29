//
//  ModuleManagement.swift
//  assistance
//
//  Created by Nicko on 29/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import Locksmith

class ModuleManagement {
    
    enum Error: ErrorType {
        case NotAuthenticated
        case DeviceIDNotFound
    }
    
    func availableModules(completed: (result: Result) -> Void) {
        guard let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"), dictionary = Locksmith.loadDataForUserAccount(userEmail), token = dictionary["token"] as? String else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        ServerConnection().get("\(GlobalConfig.baseURL)/assistance/list", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func activatedModules(completed: (result: Result) -> Void) {
        guard let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"), dictionary = Locksmith.loadDataForUserAccount(userEmail), token = dictionary["token"] as? String else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        ServerConnection().get("\(GlobalConfig.baseURL)/assistance/activations", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func activateModule(moduleID: String, completed: (result: Result) -> Void) {
        guard let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"), dictionary = Locksmith.loadDataForUserAccount(userEmail), token = dictionary["token"] as? String else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        let params: [String: AnyObject] = ["module_id": moduleID]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/assistance/activate", token: token, params: params) {
            result in
            
            completed(result: result)
        }
    }
    
    func deactivateModule(moduleID: String, completed: (result: Result) -> Void) {
        guard let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"), dictionary = Locksmith.loadDataForUserAccount(userEmail), token = dictionary["token"] as? String else {
            completed(result: { throw Error.NotAuthenticated })
            return
        }
        
        let params: [String: AnyObject] = ["module_id": moduleID]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/assistance/deactivate", token: token, params: params) {
            result in
            
            completed(result: result)
        }
    }
    
    func currentInformation(completed: (result: Result) -> Void) {
        guard let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"), dictionary = Locksmith.loadDataForUserAccount(userEmail), token = dictionary["token"] as? String else {
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
        guard let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail"), dictionary = Locksmith.loadDataForUserAccount(userEmail), token = dictionary["token"] as? String else {
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
    
}
