//
//  Contact.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import Contacts
import RealmSwift

class Contact: Sensor {

    dynamic var contactType: CNContactType = .Person
    
    dynamic var namePrefix: String = ""
    dynamic var givenName: String = ""
    dynamic var middleName: String = ""
    dynamic var familyName: String = ""
    dynamic var previousFamilyName: String = ""
    dynamic var nameSuffix: String = ""
    dynamic var nickname: String = ""
    
    dynamic var phoneticGivenName: String = ""
    dynamic var phoneticMiddleName: String = ""
    dynamic var phoneticFamilyName: String = ""
    
    dynamic var organizationName: String = ""
    dynamic var departmentName: String = ""
    dynamic var jobTitle: String = ""
    
    dynamic var note: String = ""
    
    dynamic var birthdayDay: Int = NSDateComponentUndefined
    dynamic var birthdayMonth: Int = NSDateComponentUndefined
    dynamic var birthdayYear: Int = NSDateComponentUndefined
    
    let phoneNumbers = List<LabeledValue>()
    let emailAddresses = List<LabeledValue>()
    
    dynamic var isNew: Bool = true
    dynamic var isUpdated: Bool = false
    dynamic var isDeleted: Bool = false
    
    convenience init(contact: CNContact) {
        self.init()
        
        id = contact.identifier
        
        setPropertiesFromContact(contact)
        setOrUpdateListsWithContact(contact)
    }
    
    func setPropertiesFromContact(contact: CNContact) {
        contactType = contact.contactType
        
        namePrefix = contact.namePrefix
        givenName = contact.givenName
        middleName = contact.middleName
        familyName = contact.familyName
        previousFamilyName = contact.previousFamilyName
        nameSuffix = contact.nameSuffix
        nickname = contact.nickname
        
        phoneticGivenName = contact.phoneticGivenName
        phoneticMiddleName = contact.phoneticMiddleName
        phoneticFamilyName = contact.phoneticMiddleName
        
        organizationName = contact.organizationName
        departmentName = contact.departmentName
        jobTitle = contact.jobTitle
        
        note = contact.note
        
        if let birthday = contact.birthday {
            birthdayDay = birthday.day
            birthdayMonth = birthday.month
            birthdayYear = birthday.year
        }
    }
    
    func updatePropertiesWithContact(contact: CNContact) {
        
        if id != contact.identifier || contactType != contact.contactType || namePrefix != contact.namePrefix || givenName != contact.givenName || middleName != contact.middleName || familyName != contact.familyName || previousFamilyName != contact.previousFamilyName || nameSuffix != contact.nameSuffix || nickname != contact.nickname || phoneticGivenName != contact.phoneticGivenName || phoneticMiddleName != contact.phoneticMiddleName || phoneticFamilyName != contact.phoneticMiddleName || organizationName != contact.organizationName || departmentName != contact.departmentName || jobTitle != contact.jobTitle || note != contact.note {
            
            if !isNew { isUpdated = true }
            setPropertiesFromContact(contact)
        }
        
        if let birthday = contact.birthday where birthdayDay != birthday.day || birthdayMonth != birthday.month || birthdayYear != birthday.year {
            
            if !isNew { isUpdated = true }
            setPropertiesFromContact(contact)
        }
        
        setOrUpdateListsWithContact(contact)
    }
    
    func setOrUpdateListsWithContact(contact: CNContact) {
        
        do {
            try Realm().objects(LabeledValue).forEach {
                if ($0.linkingObjects(Contact.self, forProperty: "phoneNumbers").contains(self)) {
                    $0.isDeleted = true
                }
            }
            
            for labeledPhoneNumber in contact.phoneNumbers {
                if let phoneNumbersResult = try? Realm().objects(LabeledValue).filter("label == '\(labeledPhoneNumber.label)' && value == '\((labeledPhoneNumber.value as! CNPhoneNumber).stringValue)'") where phoneNumbersResult.map({ $0.linkingObjects(Contact.self, forProperty: "phoneNumbers").contains(self) }).contains(true) {
                    phoneNumbersResult.forEach {
                        if $0.linkingObjects(Contact.self, forProperty: "phoneNumbers").contains(self) {
                            $0.isDeleted = false
                        }
                    }
                } else {
                    let newNumber = LabeledValue(label: labeledPhoneNumber.label, value: (labeledPhoneNumber.value as! CNPhoneNumber).stringValue)
                    _ = try? Realm().add(newNumber)
                    phoneNumbers.append(newNumber)
                    if !isNew { isUpdated = true }
                }
            }
            
            for labeledEmailAddress in contact.emailAddresses {
                if let emailAddressesResult = try? Realm().objects(LabeledValue).filter("label == '\(labeledEmailAddress.label)' && value == '\(labeledEmailAddress.value as! String)'") where emailAddressesResult.map({ $0.linkingObjects(Contact.self, forProperty: "emailAddresses").contains(self) }).contains(true) {
                    emailAddressesResult.forEach {
                        if $0.linkingObjects(Contact.self, forProperty: "emailAddresses").contains(self) {
                            $0.isDeleted = false
                        }
                    }
                } else {
                    let newAddress = LabeledValue(label: labeledEmailAddress.label, value: labeledEmailAddress.value as! String)
                    _ = try? Realm().add(newAddress)
                    emailAddresses.append(newAddress)
                    if !isNew { isUpdated = true }
                }
            }
            
            try Realm().objects(LabeledValue).filter("isDeleted == true").forEach {
                if ($0.linkingObjects(Contact.self, forProperty: "phoneNumbers").contains(self)) {
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
        var dictionary: [String: AnyObject] = ["type": "contact",
            "created": created.ISO8601String()!,
            "globalContactId": id,
            "contactType": contactType.rawValue,
            "namePrefix": namePrefix,
            "givenName": givenName,
            "middleName": middleName,
            "familyName": familyName,
            "previousFamilyName": previousFamilyName,
            "nameSuffix": nameSuffix,
            "nickname": nickname,
            "phoneticGivenName": phoneticGivenName,
            "phoneticMiddleName": phoneticMiddleName,
            "phoneticFamilyName": phoneticFamilyName,
            "organizationName": organizationName,
            "departmentName": departmentName,
            "jobTitle": jobTitle,
            "note": note,
            "isDeleted": isDeleted]
        
//        if birthdayDay != NSDateComponentUndefined {
//            dictionary["birthdayDay"] = birthdayDay
//        }
//        
//        if birthdayMonth != NSDateComponentUndefined {
//            dictionary["birthdayMonth"] = birthdayMonth
//        }
//        
//        if birthdayYear != NSDateComponentUndefined {
//            dictionary["birthdayYear"] = birthdayYear
//        }
        
        if phoneNumbers.count > 0 {
            dictionary["phoneNumbers"] = phoneNumbers.map { $0.dictionary() }
        }
        
        if emailAddresses.count > 0 {
            dictionary["emailAddresses"] = emailAddresses.map { $0.dictionary() }
        }
        
        return dictionary
    }
    
}
