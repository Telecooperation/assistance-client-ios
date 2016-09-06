//
//  MobileConnection.swift
//  assistance
//
//  Created by Nickolas Guendling on 27/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreTelephony

class MobileConnection: Sensor {
    
    dynamic var carrierName: String = ""
    dynamic var mobileCountryCode: String = ""
    dynamic var mobileNetworkCode: String = ""
    dynamic var voipAvailable: Bool = false
    
    convenience init(carrier: CTCarrier) {
        self.init()
        
        if let carrierName = carrier.carrierName {
            self.carrierName = carrierName
        }
        if let mobileCountryCode = carrier.mobileCountryCode {
            self.mobileCountryCode = mobileCountryCode
        }
        if let mobileNetworkCode = carrier.mobileNetworkCode {
            self.mobileNetworkCode = mobileNetworkCode
        }
        self.voipAvailable = carrier.allowsVOIP
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "mobileconnection",
            "created": created.ISO8601String()!,
            "carrierName": carrierName,
            "mobileCountryCode": mobileCountryCode,
            "mobileNetworkCode": mobileNetworkCode,
            "voipAvailable": voipAvailable]
    }
    
}
