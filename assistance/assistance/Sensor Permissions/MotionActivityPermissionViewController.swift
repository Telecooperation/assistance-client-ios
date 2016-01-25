//
//  MotionActivityPermissionViewController.swift
//  assistance
//
//  Created by Nicko on 24/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import CoreMotion

class MotionActivityPermissionViewController: UIViewController {

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
        CMMotionActivityManager().queryActivityStartingFromDate(NSDate(), toDate: NSDate(), toQueue: NSOperationQueue()) {
            _, error in
            
            if error == nil {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func openSettings(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
