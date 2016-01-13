//
//  Sensor.swift
//  Labels
//
//  Created by Nickolas Guendling on 09/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift
import ISO8601

class Sensor: Object, Equatable, Hashable {

    dynamic var id: String = NSUUID().UUIDString
    
    dynamic var created: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func setSynced() {

    }
    
    func dictionary() -> [String: AnyObject] {
        return ["created": created.ISO8601String()!]
    }
    
}

func ==(lhs: Sensor, rhs: Sensor) -> Bool {
    return lhs.isEqual(rhs)
}
