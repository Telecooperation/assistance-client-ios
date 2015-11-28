//
//  SensorManager.swift
//  Labels
//
//  Created by Nicko on 11/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

@objc protocol SensorManager {
    
    var sensorName: String { get }
    
    var uploadInterval: Double { get }
    var updateInterval: Double { get }
    
    func sensorData() -> [Sensor]
    func sensorDataDidUpload(data: [Sensor])
    
    optional func didStart()
    optional func didStop()
}

extension SensorManager {
    
    func start() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(sensorName)IsActive")
        
        didStart?()
    }
    
    func stop() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "\(sensorName)IsActive")
        
        didStop?()
    }
    
    func isActive() -> Bool {
        if NSUserDefaults.standardUserDefaults().objectForKey("\(sensorName)IsActive") == nil {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(sensorName)IsActive")
        }
        
        return NSUserDefaults.standardUserDefaults().boolForKey("\(sensorName)IsActive")
    }
    
    func shouldUpload() -> Bool {
        return NSDate().timeIntervalSinceDate(lastUploadTime()) >= uploadInterval
    }
    
    func lastUploadTime() -> NSDate {
        if NSUserDefaults.standardUserDefaults().objectForKey("\(sensorName)LastUploadTime") == nil {
            NSUserDefaults.standardUserDefaults().setObject(NSDate.distantPast(), forKey: "\(sensorName)LastUploadTime")
        }
        
        return NSUserDefaults.standardUserDefaults().objectForKey("\(sensorName)LastUploadTime") as! NSDate
    }
    
    func didUpload() {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "\(sensorName)LastUploadTime")
    }
    
    func shouldUpdate() -> Bool {
        return NSDate().timeIntervalSinceDate(lastUpdateTime()) >= updateInterval
    }
    
    func lastUpdateTime() -> NSDate {
        if NSUserDefaults.standardUserDefaults().objectForKey("\(sensorName)LastUpdateTime") == nil {
            NSUserDefaults.standardUserDefaults().setObject(NSDate.distantPast(), forKey: "\(sensorName)LastUpdateTime")
        }
        
        return NSUserDefaults.standardUserDefaults().objectForKey("\(sensorName)LastUpdateTime") as! NSDate
    }
    
    func didUpdate() {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "\(sensorName)LastUpdateTime")
    }
}
