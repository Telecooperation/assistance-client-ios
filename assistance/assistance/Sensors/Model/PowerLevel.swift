//
//  PowerLevel.swift
//  assistance
//
//  Created by Nickolas Guendling on 09/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class PowerLevel: Sensor {

    dynamic var percent: Float = 0
    
    convenience init(percent: Float) {
        self.init()
        
        self.percent = percent
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "powerlevel",
            "created": created.ISO8601String()!,
            "percent": percent]
    }
    
}
