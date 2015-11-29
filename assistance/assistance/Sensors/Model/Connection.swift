//
//  Connection.swift
//  assistance
//
//  Created by Nicko on 21/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class Connection: Sensor {
    
    dynamic var isWifi: Bool = false
    dynamic var isMobile: Bool = false
    
    convenience init(isWifi: Bool, isMobile: Bool) {
        self.init()
        
        self.isWifi = isWifi
        self.isMobile = isMobile
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "connection",
            "created": created.ISO8601String(),
            "isWifi": isWifi,
            "isMobile": isMobile]
    }
}
