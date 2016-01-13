//
//  Alarm.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import EventKit

class Alarm: Sensor {
    
    dynamic var offset: Double = 0
    dynamic var absoluteDate: NSDate = NSDate.distantPast()
    
    dynamic var proximity: EKAlarmProximity = .None
    dynamic var locationTitle: String = ""
    dynamic var locationLatitude: Double = -1024
    dynamic var locationLongitude: Double = -1024
    dynamic var locationRadius: Double = 0
    
    dynamic var isDeleted: Bool = false
    
    convenience init(alarm: EKAlarm) {
        self.init()
        
        offset = alarm.relativeOffset
        
        if let absoluteDate = alarm.absoluteDate {
            self.absoluteDate = absoluteDate
        }
        
        proximity = alarm.proximity
        
        if let location = alarm.structuredLocation {
            locationTitle = location.title
            if let geoLocation = location.geoLocation {
                locationLatitude = geoLocation.coordinate.latitude
                locationLongitude = geoLocation.coordinate.longitude
            }
            locationRadius = location.radius
        }
        
    }
    
    override static func indexedProperties() -> [String] {
        return ["value"]
    }
    
    override func dictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = ["type": 0,
            "defaultOffset": false]
        
        if absoluteDate != NSDate.distantPast() {
            dictionary["absoluteDate"] = absoluteDate.ISO8601String()!
        } else {
            dictionary["offset"] = offset
        }
        
        if proximity != .None {
            dictionary["proximity"] = proximity.rawValue
            dictionary["locationTitle"] = locationTitle
            
            if locationLatitude != -1024 {
                dictionary["locationLatitude"] = locationLatitude
            }
            if locationLongitude != -1024 {
                dictionary["locationLongitude"] = locationLongitude
            }
            
            dictionary["locationRadius"] = locationRadius
        }
        
        return dictionary
    }
    
}
