//
//  ContactManager.swift
//  assistance
//
//  Created by Nickolas Guendling on 05/12/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import Contacts

import RealmSwift

class ContactManager: NSObject, SensorManager {
    
    let sensorType = "contact"
    
    var sensorConfiguration = NSMutableDictionary()
    
    var collecting = false
    
    static let sharedManager = ContactManager()
    
    let realm = try! Realm()
    let contactStore = CNContactStore()
    
    override init() {
        super.init()
        
        initSensorManager()
        
        if isActive() {
            start()
        }
    }
    
    func needsSystemAuthorization() -> Bool {
        return CNContactStore.authorizationStatusForEntityType(.Contacts) != .Authorized
    }
    
    func requestAuthorizationFromViewController(viewController: UIViewController, completed: (granted: Bool, error: NSError?) -> Void) {
        if CNContactStore.authorizationStatusForEntityType(.Contacts) != .Authorized {
            contactStore.requestAccessForEntityType(.Contacts) {
                granted, error in
                
                if granted {
                    self.grantAuthorization()
                } else {
                    self.denySystemAuthorization()
                }
                
                completed(granted: granted, error: error)
            }
        }
    }
    
    func didStart() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contactsChanged", name: CNContactStoreDidChangeNotification, object: nil)
        
        contactsChanged()
    }
    
    func didStop() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        realm.delete(realm.objects(Contact))
    }
    
    func contactsChanged() {
        
        collecting = true
        
        dispatch_async(dispatch_get_main_queue(), {
            _ = try? self.realm.write {
                self.realm.objects(Contact).forEach { $0.isDeleted = true }
            }
        })

        _ = try? contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPreviousFamilyNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPhoneticFamilyNameKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactBirthdayKey, CNContactNonGregorianBirthdayKey, CNContactNoteKey, CNContactImageDataKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey, CNContactTypeKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactDatesKey, CNContactUrlAddressesKey, CNContactRelationsKey, CNContactSocialProfilesKey, CNContactInstantMessageAddressesKey])) {
            contact, _ in
            
            let savedContacts = self.realm.objects(Contact).filter("id == '\(contact.identifier)'")
            dispatch_async(dispatch_get_main_queue(), {
                _ = try? self.realm.write {
                    if savedContacts.count > 0 {
                        savedContacts.first!.isDeleted = false
                        savedContacts.first!.updatePropertiesWithContact(contact)
                    } else {
                        self.realm.add(Contact(contact: contact))
                    }
                }
            })
        }
        
        collecting = false
    }
    
    func sensorData() -> [Sensor] {
        if isActive() && shouldUpdate() && !collecting {
            return Array(realm.objects(Contact).filter("isNew == true || isUpdated == true || isDeleted == true").toArray().prefix(20))
        }
        
        return [Sensor]()
    }
    
    func sensorDataDidUpdate(data: [Sensor]) {
        _ = try? realm.write {
            for contact in data {
                contact.setSynced()
            }
        }
        
        if realm.objects(Contact).count == 0 {
            didUpdate()
        }
    }

}
