//
//  UserManagement.swift
//  Labels
//
//  Created by Nicko on 21/07/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class UserManagement {
    
    let baseURL = "http://130.83.163.146" // 130.83.163.146 & 130.83.163.115
    
    func register(email: String, password: String, completed: (succeeded: Bool, message: String) -> ()) {
        
        let params: [String: String] = ["email": email, "password": password]
        
        ServerConnection().post("\(baseURL)/users/register", token: nil, params: params) { (succeeded: Bool, message: String) -> () in
            completed(succeeded: succeeded, message: message)
        }
    }
    
    func login(email: String, password: String, completed: (succeeded: Bool, message: String) -> ()) {
        
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
        
        ServerConnection().post("\(baseURL)/users/login", token: nil, params: params) { (succeeded: Bool, message: String) -> () in
            completed(succeeded: succeeded, message: message)
        }
    }
    
    func resetPassword(email: String, completed: (succeeded: Bool, message: String) -> ()) {
        
        let params: [String: String] = ["email": email]
        
        ServerConnection().post("\(baseURL)/users/password", token: nil, params: params) { (succeeded: Bool, message: String) -> () in
            completed(succeeded: succeeded, message: message)
        }
    }
    
    func shortProfile(token: String, completed: (succeeded: Bool, message: String) -> ()) {
        
        ServerConnection().get("\(baseURL)/users/profile/short", token: token) { (succeeded: Bool, message: String) -> () in
            completed(succeeded: succeeded, message: message)
        }
    }
    
    func longProfile(token: String, completed: (succeeded: Bool, message: String) -> ()) {
        
        ServerConnection().get("\(baseURL)/users/profile/long", token: token) { (succeeded: Bool, message: String) -> () in
            completed(succeeded: succeeded, message: message)
        }
    }
    
    func updateProfile(token: String, firstName: String, lastName: String, completed: (succeeded: Bool, message: String) -> ()) {
        
        let params: [String: AnyObject] = ["firstname": firstName, "lastname": lastName]
        
        ServerConnection().put("\(baseURL)/users/profile", token: token, params: params) { (succeeded: Bool, message: String) -> () in
            completed(succeeded: succeeded, message: message)
        }
    }
}