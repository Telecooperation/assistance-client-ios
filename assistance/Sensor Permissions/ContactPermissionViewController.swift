//
//  ContactPermissionViewController.swift
//  assistance
//
//  Created by Nicko on 15/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import Contacts

class ContactPermissionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        dismissIfAuthorized()
    }
    
    func applicationWillEnterForeground() {
        dismissIfAuthorized()
    }
    
    func dismissIfAuthorized() {
        if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func openSettings(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
