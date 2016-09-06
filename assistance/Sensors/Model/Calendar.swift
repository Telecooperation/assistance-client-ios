//
//  Calendar.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import EventKit
import RealmSwift

class Calendar: Sensor {
    
    dynamic var calendarId: String = ""
    dynamic var allDay: Bool = false
    dynamic var availability: EKEventAvailability = .NotSupported
    dynamic var notes: String = ""
    dynamic var startDate: NSDate = NSDate.distantPast()
    dynamic var endDate: NSDate = NSDate.distantPast()
    dynamic var location: String = ""
    dynamic var status: EKEventStatus = .None
    dynamic var title: String = ""
    
    dynamic var recurrenceRule: String = ""
    let alarms = List<Alarm>()
    
    dynamic var URL: String = ""
    dynamic var isDetached: Bool = false
    dynamic var lastModifiedDate: NSDate = NSDate.distantPast()
    
    dynamic var isNew: Bool = true
    dynamic var isUpdated: Bool = false
    dynamic var isDeleted: Bool = false
    
    convenience init(event: EKEvent) {
        self.init()
        
        id = event.eventIdentifier
        
        setPropertiesFromEvent(event)
        setOrUpdateListsWithEvent(event)
    }
    
    func setPropertiesFromEvent(event: EKEvent) {
        calendarId = event.calendar.calendarIdentifier
        allDay = event.allDay
        availability = event.availability
        startDate = event.startDate
        endDate = event.endDate
        
        if let notes = event.notes {
            self.notes = notes
        }
        
        if let location = event.location {
            self.location = location
        }
        
        status = event.status
        title = event.title
        
        if let recurrenceRules = event.recurrenceRules, recurrenceRule = recurrenceRules.first {
            self.recurrenceRule = recurrenceRule.description.componentsSeparatedByString(" RRULE ")[1]
        }
        
        if let URL = event.URL {
            self.URL = URL.absoluteString
        }
        
        isDetached = event.isDetached
        
        if let lastModifiedDate = event.lastModifiedDate {
            self.lastModifiedDate = lastModifiedDate
        }
        
    }
    
    func updatePropertiesWithEvent(event: EKEvent) {
        
        if id != event.eventIdentifier || calendarId != event.calendar.calendarIdentifier || allDay != event.allDay || availability != event.availability || startDate != event.startDate || endDate != event.endDate || status != event.status || title != event.title || isDetached != event.isDetached {
            
            if !isNew { isUpdated = true }
            setPropertiesFromEvent(event)
        }
        
        if let notes = event.notes where self.notes != notes {
            if !isNew { isUpdated = true }
            setPropertiesFromEvent(event)
        }
        
        if let location = event.location where self.location != location {
            if !isNew { isUpdated = true }
            setPropertiesFromEvent(event)
        }
        
        if let recurrenceRules = event.recurrenceRules, recurrenceRule = recurrenceRules.first {
            let recurrenceRuleString = recurrenceRule.description.componentsSeparatedByString(" RRULE ")[1]
            
            if self.recurrenceRule != recurrenceRuleString {
                if !isNew { isUpdated = true }
                setPropertiesFromEvent(event)
            }
        }
        
        if let URL = event.URL where self.URL != URL.absoluteString {
            if !isNew { isUpdated = true }
            setPropertiesFromEvent(event)
        }
        
        if let lastModifiedDate = event.lastModifiedDate where self.lastModifiedDate != lastModifiedDate {
            if !isNew { isUpdated = true }
            setPropertiesFromEvent(event)
        }
        
        setOrUpdateListsWithEvent(event)
    }
    
    func setOrUpdateListsWithEvent(event: EKEvent) {
        
        do {
            try Realm().objects(Alarm).forEach {
                if ($0.linkingObjects(Calendar.self, forProperty: "alarms").contains(self)) {
                    $0.isDeleted = true
                }
            }
            if let alarms = event.alarms {
                for alarm in alarms {
                    var predicate = "offset == \(alarm.relativeOffset) && proximity == \(alarm.proximity.rawValue)"
                    
                    if let absoluteDate = alarm.absoluteDate {
                        predicate += " && absoluteDate == \(absoluteDate)"
                    }
                    
                    if let location = alarm.structuredLocation {
                        predicate += " && locationTitle == '\(location.title)'"
                        if let geoLocation = location.geoLocation {
                            predicate += " && locationLatitude == \( geoLocation.coordinate.latitude)"
                            predicate += " && locationLongitude == \(geoLocation.coordinate.longitude)"
                        }
                        predicate += " && locationRadius == \(location.radius)"
                    }
                    
                    if let alarmsResult = try? Realm().objects(Alarm).filter(predicate) where alarmsResult.map({ $0.linkingObjects(Calendar.self, forProperty: "alarms").contains(self) }).contains(true) {
                        alarmsResult.forEach {
                            if $0.linkingObjects(Calendar.self, forProperty: "alarms").contains(self) {
                                $0.isDeleted = false
                            }
                        }
                    } else {
                        let newAlarm = Alarm(alarm: alarm)
                        _ = try? Realm().add(newAlarm)
                        self.alarms.append(newAlarm)
                        if !isNew { isUpdated = true }
                    }
                }
            }
            
            try Realm().objects(Alarm).filter("isDeleted == true").forEach {
                if ($0.linkingObjects(Calendar.self, forProperty: "alarms").contains(self)) {
                    isUpdated = true
                    _ = try? Realm().delete($0)
                }
            }
        } catch { }
    }
    
    override func setSynced() {
        isNew = false
        isUpdated = false
        
        if isDeleted {
            _ = try? Realm().delete(self)
        }
    }
    
    override func dictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = ["type": "calendar",
            "created": created.ISO8601String()!,
            "eventId": id,
            "calendarId": calendarId,
            "allDay": allDay,
            "availability": intValueForAvailability(),
            "description": notes,
            "startDate": startDate.ISO8601String()!,
            "endDate": endDate.ISO8601String()!,
            "location": location,
            "status": intValueForStatus(),
            "title": title,
            "recurrenceRule": recurrenceRule,
            "URL": URL,
            "isDetached": isDetached,
            "lastModifiedDate": lastModifiedDate.ISO8601String()!,
            "isDeleted": isDeleted]
        
        if alarms.count > 0 {
            dictionary["alarms"] = alarms.map { $0.dictionary() }
        }
        
        return dictionary
    }
    
    func intValueForAvailability() -> Int {
        switch availability {
            case .NotSupported:
                return -1
            case .Busy:
                return 0
            case .Free:
                return 1
            case .Tentative:
                return 2
            case .Unavailable:
                return 3
        }
    }
    
    func intValueForStatus() -> Int {
        switch status {
            case .None:
                return -1
            case .Tentative:
                return 0
            case .Confirmed:
                return 1
            case .Canceled:
                return 2
        }
    }
    
}
