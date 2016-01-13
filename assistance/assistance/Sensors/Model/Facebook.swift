//
//  Facebook.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

class Facebook: Sensor {

    dynamic var oauthToken: String = ""
    dynamic var isNew: Bool = true
    
    var permissions: [String] {
        get {
            return _savedPermissions.map { $0.stringValue }
        }
        set {
            _savedPermissions.removeAll()
            _savedPermissions.appendContentsOf(newValue.map({ RealmString(value: [$0]) }))
        }
    }
    let _savedPermissions = List<RealmString>()
    
    var declinedPermissions: [String] {
        get {
            return _savedPermissions.map { $0.stringValue }
        }
        set {
            _savedPermissions.removeAll()
            _savedPermissions.appendContentsOf(newValue.map({ RealmString(value: [$0]) }))
        }
    }
    let _savedDeclinedPermissions = List<RealmString>()
    
    override static func ignoredProperties() -> [String] {
        return ["permissions", "declinedPermissions"]
    }
    
    convenience init(oauthToken: String, permissions: [String], declinedPermissions: [String]) {
        self.init()
        
        self.oauthToken = oauthToken
        self.permissions = permissions
        self.declinedPermissions = declinedPermissions
    }
    
    override func setSynced() {
        isNew = false
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "facebooktoken",
            "created": created.ISO8601String()!,
            "oauthToken": oauthToken,
            "permissions": permissions,
            "declinedPermissions": declinedPermissions]
    }
    
}
