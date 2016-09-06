//
//  MotionActivity.swift
//  Labels
//
//  Created by Nickolas Guendling on 09/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion

class MotionActivity: Sensor {

    dynamic var walking: Int = 0
    dynamic var running: Int = 0
    dynamic var cycling: Int = 0
    dynamic var driving: Int = 0
    dynamic var stationary: Int = 0
    dynamic var unknown: Int = 0
    
    convenience init(motionActivity: CMMotionActivity) {
        self.init()
        
        created = motionActivity.startDate
        
        var probability = 0
        switch motionActivity.confidence {
            case .High: probability = 100
            case .Medium: probability = 66
            case .Low: probability = 33
        }
        
        if motionActivity.walking {
            walking = probability
        }
        if motionActivity.running {
            running = probability
        }
        if motionActivity.cycling {
            cycling = probability
        }
        if motionActivity.automotive {
            driving = probability
        }
        if motionActivity.stationary {
            stationary = probability
        }
        if motionActivity.unknown {
            unknown = probability
        }
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "motionactivity",
                "created": created.ISO8601String()!,
                "walking": walking,
                "running": running,
                "cycling": cycling,
                "driving": driving,
                "stationary": stationary,
                "unknown": unknown]
    }
    
}
