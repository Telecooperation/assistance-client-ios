//
//  AppDelegate.swift
//  assistance
//
//  Created by Nickolas Guendling on 08/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // TODO: Remove debug line!
        NSUserDefaults.standardUserDefaults().removeObjectForKey("sensorConfiguration")
        
        createSensorConfiguration()
        
        return true
    }
    
    func createSensorConfiguration() {
        if NSUserDefaults.standardUserDefaults().objectForKey("sensorConfiguration") == nil {
            if let path = NSBundle.mainBundle().pathForResource("Sensors", ofType: "plist"), sensorConfiguration = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
                NSUserDefaults.standardUserDefaults().setObject(sensorConfiguration, forKey: "sensorConfiguration")
            }
        }
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        DataSync().syncData()
        completionHandler(.NewData) // was .NoData
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
