//
//  FacebookSensorManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookManager: NSObject, SensorManager {

    let sensorType = "facebooktoken"
    
    var sensorConfiguration = NSMutableDictionary()
    
    static let sharedManager = FacebookManager()
    
    let realm = try! Realm()
    let fbLoginManager = FBSDKLoginManager()
    
    override init() {
        super.init()
        
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    func needsSystemAuthorization() -> Bool {
        return FBSDKAccessToken.currentAccessToken() == nil
    }
    
    func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void) {
        if FBSDKAccessToken.currentAccessToken() == nil {
            fbLoginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"], fromViewController: viewController) {
                result, error in
                
                var granted = false
                if error != nil {
                    self.denyAuthorization()
                } else if result.isCancelled {
                    self.denyAuthorization()
                } else {
                    self.grantAuthorization()
                    granted = true
                    
                    let permissions = FBSDKAccessToken.currentAccessToken().permissions.map { String($0) }
                    let declinedPermissions = FBSDKAccessToken.currentAccessToken().declinedPermissions.map { String($0) }
                    dispatch_async(dispatch_get_main_queue(), {
                        _ = try? self.realm.write {
                            self.realm.add(Facebook(oauthToken: FBSDKAccessToken.currentAccessToken().tokenString, permissions: permissions, declinedPermissions: declinedPermissions))
                        }
                    })
                }
                completed(granted: granted, error: error)
            }
        }
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() {
            return Array(realm.objects(Facebook).filter("isNew == true").toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for facebook in data {
                facebook.setSynced()
            }
        }
        
        if realm.objects(Facebook).count == 0 {
            didUpdate()
        }
    }

}
