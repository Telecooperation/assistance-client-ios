//
//  LoudnessManager.swift
//  assistance
//
//  Created by Nicko on 28/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import AVFoundation

import RealmSwift

//
// Not used because ringer volume seems not to be currently accessible on iOS
//

class LoudnessManager: NSObject, SensorManager {
    
    let sensorName = "loudness"
    
    let uploadInterval = 60.0
    let updateInterval = 5.0
    
    static let sharedManager = LoudnessManager()
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private struct Observation {
        static let VolumeKey = "outputVolume"
        static let Context = UnsafeMutablePointer<Void>()
    }
    
    let realm = try! Realm()
    
    override init() {
        super.init()
        
        if isActive() {
            start()
        }
    }
    
    func didStart() {
        do {
            try audioSession.setActive(true)
            audioSession.addObserver(self, forKeyPath: Observation.VolumeKey, options: [.Initial, .New], context: Observation.Context)
        } catch {
            print("Failed to activate audio session")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == Observation.Context {
            if keyPath == Observation.VolumeKey, let volume = (change?[NSKeyValueChangeNewKey] as? NSNumber)?.floatValue {
                print("Volume: \(volume)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    _ = try? self.realm.write {
                        self.realm.add(Loudness(loudness: volume))
                    }
                })
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func didStop() {
        audioSession.removeObserver(self, forKeyPath: Observation.VolumeKey, context: Observation.Context)
        
        realm.delete(realm.objects(Loudness))
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpload() {
            return Array(realm.objects(Loudness).toArray().prefix(50))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpload(data: [Sensor]) {
        _ = try? realm.write {
            for loudness in data {
                self.realm.delete(loudness)
            }
        }
        
        if realm.objects(Loudness).count < 50 {
            didUpload()
        }
    }
    
}
