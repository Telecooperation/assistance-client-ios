//
//  Position.swift
//  Labels
//
//  Created by Nicko on 09/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreLocation

class Position: Sensor {

    dynamic var latitude: Double = 1024
    dynamic var longitude: Double = 1024
    
    dynamic var speed: Float = 0
    dynamic var altitude: Double = 0
    dynamic var course: Int = 0
    dynamic var floor: Int = -1024
    
    dynamic var accuracyHorizontal: Double = 0
    dynamic var accuracyVertical: Double = 0
    
    convenience init(location: CLLocation) {
        self.init()
        
        created = location.timestamp
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        speed = Float(location.speed)
        altitude = location.altitude
        course = Int(location.course)
        if let locationFloor = location.floor {
            floor = locationFloor.level
        }
        
        accuracyHorizontal = location.horizontalAccuracy
        accuracyVertical = location.verticalAccuracy
    }
    
    override func dictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = ["type": "position",
            "created": created.ISO8601String(),
            "latitude": latitude,
            "longitude": longitude,
            "speed": speed,
            "altitude": altitude,
            "course": course,
            "accuracyHorizontal": accuracyHorizontal,
            "accuracyVertical": accuracyVertical]
        
        if floor != -1024 {
            dictionary["floor"] = floor
        }
        
        return dictionary
    }
}
