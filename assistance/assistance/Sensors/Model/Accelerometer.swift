//
//  Accelerometer.swift
//  Labels
//
//  Created by Nickolas Guendling on 09/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion

class Accelerometer: Sensor {

    dynamic var x: Double = 0
    dynamic var y: Double = 0
    dynamic var z: Double = 0
    
    convenience init(accelerometerData: CMAccelerometerData) {
        self.init()
        
        x = accelerometerData.acceleration.x
        y = accelerometerData.acceleration.y
        z = accelerometerData.acceleration.z
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "accelerometer",
                "created": created.ISO8601String()!,
                "x": x,
                "y": y,
                "z": z]
    }
    
}
