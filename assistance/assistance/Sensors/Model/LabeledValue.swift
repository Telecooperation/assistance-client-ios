//
//  LabeledValue.swift
//  assistance
//
//  Created by Nickolas Guendling on 10/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import Contacts

class LabeledValue: Sensor {
    
    dynamic var label: String = ""
    dynamic var value: String = ""
    
    dynamic var isDeleted: Bool = false
    
    convenience init(label: String, value: String) {
        self.init()
        
        self.label = label
        self.value = value
    }
    
    override static func indexedProperties() -> [String] {
        return ["value"]
    }
    
    override func dictionary() -> [String: AnyObject] {
        return ["label": label,
                "value": value]
    }
    
}
