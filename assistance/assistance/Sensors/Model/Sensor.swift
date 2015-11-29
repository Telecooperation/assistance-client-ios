//
//  Sensor.swift
//  Labels
//
//  Created by Nicko on 09/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift
import ISO8601

class Sensor: Object {

    dynamic var id: String = NSUUID().UUIDString
    
    dynamic var created: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func dictionary() -> [String: AnyObject] {
        return ["created": created.ISO8601String()]
    }
}
