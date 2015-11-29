//
//  Loudness.swift
//  assistance
//
//  Created by Nicko on 28/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

class Loudness: Sensor {
    
    dynamic var loudness: Float = 0
    
    convenience init(loudness: Float) {
        self.init()
        
        self.loudness = loudness
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["type": "loudness",
            "created": created.ISO8601String(),
            "loudness": loudness]
    }
}
