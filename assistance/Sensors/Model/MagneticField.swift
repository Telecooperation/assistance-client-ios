//
//  MagneticField.swift
//  Labels
//
//  Created by Nickolas Guendling on 09/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion

class MagneticField: Sensor {

    dynamic var x: Double = 0
    dynamic var y: Double = 0
    dynamic var z: Double = 0
    
    convenience init(magnetometerData: CMMagnetometerData) {
        self.init()
        
        x = magnetometerData.magneticField.x
        y = magnetometerData.magneticField.y
        z = magnetometerData.magneticField.z
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "magneticfield",
                "created": created.ISO8601String()!,
                "x": x,
                "y": y,
                "z": z]
    }
    
}
