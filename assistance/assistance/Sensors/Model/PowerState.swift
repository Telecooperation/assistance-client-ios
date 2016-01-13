//
//  PowerState.swift
//  Labels
//
//  Created by Nickolas Guendling on 20/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

@objc enum ChargingState: Int {
    case None, Low, Okay, Full, Malfunction
}

class PowerState: Sensor {

    dynamic var isCharging: Bool = false
    dynamic var percent: Float = 0
    dynamic var chargingState: ChargingState = .None
    dynamic var powerSaveMode: Bool = false
    
    convenience init(isCharging: Bool, percent: Float, chargingState: ChargingState, powerSaveMode: Bool) {
        self.init()
        
        self.percent = percent
        self.isCharging = isCharging
        self.chargingState = chargingState
        self.powerSaveMode = powerSaveMode
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "powerstate",
                "created": created.ISO8601String()!,
                "isCharging": isCharging,
                "percent": percent,
                "chargingState": chargingState.rawValue,
                "powerSaveMode": powerSaveMode]
    }
    
}
