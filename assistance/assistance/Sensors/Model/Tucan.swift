//
//  Tucan.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class Tucan: Sensor {

    dynamic var username: String = ""
    dynamic var password: String = ""
    
    dynamic var isNew: Bool = true
    
    convenience init(username: String, password: String) {
        self.init()
        
        self.username = username
        self.password = password
    }
    
    override func setSynced() {
        isNew = false
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "tucancredentials",
            "created": created.ISO8601String()!,
            "username": username,
            "password": password]
    }
    
}
