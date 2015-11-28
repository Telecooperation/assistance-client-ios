//
//  WifiConnection.swift
//  eva
//
//  Created by Nicko on 27/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class WifiConnection: Sensor {
    
    dynamic var ssid: String = ""
    dynamic var bssid: String = ""
    
    convenience init(ssid: String, bssid: String) {
        self.init()
        
        self.ssid = ssid
        self.bssid = bssid
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "wificonnection",
            "created": created.ISO8601String(),
            "ssid": ssid,
            "bssid": bssid]
    }
}
