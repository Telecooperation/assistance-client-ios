//
//  Gyroscope.swift
//  Labels
//
//  Created by Nickolas Guendling on 09/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion

class Gyroscope: Sensor {

    dynamic var x: Double = 0
    dynamic var y: Double = 0
    dynamic var z: Double = 0
    
    convenience init(gyroData: CMGyroData) {
        self.init()
        
        x = gyroData.rotationRate.x
        y = gyroData.rotationRate.y
        z = gyroData.rotationRate.z
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "gyroscope",
                "created": created.ISO8601String()!,
                "x": x,
                "y": y,
                "z": z]
    }
    
}
