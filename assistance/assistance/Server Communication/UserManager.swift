//
//  UserManager.swift
//  Labels
//
//  Created by Nickolas Guendling on 21/07/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class UserManager {
    
    func register(email: String, password: String, completed: (result: Result) -> Void) {
        
        let params: [String: String] = ["email": email, "password": password]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/users/register", token: nil, params: params) {
            result in
            
            completed(result: result)
        }
    }
    
    func login(email: String, password: String, completed: (result: Result) -> Void) {
        
        var deviceDictionary = [String: String]()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey("device_id") == nil {
            deviceDictionary["os"] = UIDevice.currentDevice().systemName
            deviceDictionary["os_version"] = UIDevice.currentDevice().systemVersion
            deviceDictionary["brand"] = "Apple"
            deviceDictionary["model"] = UIDevice.currentDevice().model
            deviceDictionary["device_identifier"] = UIDevice.currentDevice().identifierForVendor?.UUIDString
        } else {
            deviceDictionary["id"] = defaults.stringForKey("device_id")
        }
            
        
        let params: [String: AnyObject] = ["email": email, "password": password, "device": deviceDictionary]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/users/login", token: nil, params: params) {
            result in
            
            completed(result: result)
        }
    }
    
    func resetPassword(email: String, completed: (result: Result) -> Void) {
        
        let params: [String: String] = ["email": email]
        
        ServerConnection().post("\(GlobalConfig.baseURL)/users/password", token: nil, params: params) {
            result in
            
            completed(result: result)
        }
    }
    
    func shortProfile(token: String, completed: (result: Result) -> Void) {
        
        ServerConnection().get("\(GlobalConfig.baseURL)/users/profile/short", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func longProfile(token: String, completed: (result: Result) -> Void) {
        
        ServerConnection().get("\(GlobalConfig.baseURL)/users/profile/long", token: token) {
            result in
            
            completed(result: result)
        }
    }
    
    func updateProfile(token: String, firstName: String, lastName: String, completed: (result: Result) -> Void) {
        
        let params: [String: AnyObject] = ["firstname": firstName, "lastname": lastName]
        
        ServerConnection().put("\(GlobalConfig.baseURL)/users/profile", token: token, params: params) {
            result in
            
            completed(result: result)
        }
    }
}