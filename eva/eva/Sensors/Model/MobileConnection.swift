//
//  MobileConnection.swift
//  eva
//
//  Created by Nicko on 27/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class MobileConnection: Sensor {
    
    dynamic var carrierName: String = ""
    dynamic var mobileCountryCode: String = ""
    dynamic var mobileNetworkCode: String = ""
    dynamic var voipAvailable: Bool = false
    
    convenience init(carrierName: String, mobileCountryCode: String, mobileNetworkCode: String, voipAvailable: Bool) {
        self.init()
        
        self.carrierName = carrierName
        self.mobileCountryCode = mobileCountryCode
        self.mobileNetworkCode = mobileNetworkCode
        self.voipAvailable = voipAvailable
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "mobileconnection",
            "created": created.ISO8601String(),
            "carrierName": carrierName,
            "mobileCountryCode": mobileCountryCode,
            "mobileNetworkCode": mobileNetworkCode,
            "voipAvailable": voipAvailable]
    }
}
