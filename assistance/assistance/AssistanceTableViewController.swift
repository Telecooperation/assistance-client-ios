//
//  AssistanceTableViewController.swift
//  assistance
//
//  Created by Nickolas Guendling on 29/11/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import CoreLocation

class AssistanceTableViewController: UITableViewController {

    var currentInfo = [
        ["moduleId": "de.tudarmstadt.informatik.tk.assistanceplatform.modules.hotplaces",
         "created": "2015-11-29T20:21:34+01:00",
         "payload": [
                        ["type": "group", "alignment": "horizontal", "distribution": [70, 30], "content":   [
                                                                                                                ["type": "text", "style": "headline", "content": "This Is an Awesome Headline!"],
                                                                                                                ["type": "text", "style": "footnote", "content": "Yeah."]
                                                                                                            ]
                        ],
                        ["type": "map", "showCurrentLocation": true, "points": [[49.877427, 8.653879], [49.877496, 8.653429], [49.877220, 8.653493]]]
                    ]
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 290.0
    }
    
//    override func viewWillAppear() {
//        super.viewWillAppear()
//        
//        ModuleManager().currentInformation {
//            result in
//            
//            do {
//                let data = try result()
//            } catch {
//                
//            }
//        }
//    }
    
    override func viewDidAppear(animated: Bool) {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            performSegueWithIdentifier("locationAuthorizationSegue", sender: self)
        } else if CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted {
            performSegueWithIdentifier("locationAuthorizationFailedSegue", sender: self)
        } else if let _ = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail") {
            DataSync().syncData()
        } else {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return currentInfo.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Card", forIndexPath: indexPath)

        let cardInfo = currentInfo[Int(indexPath.section)]
        if let payload = cardInfo["payload"] as? [[String: AnyObject]] {
            for object in payload {
                
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let iso8601date = currentInfo[section]["created"] as! String
        guard let date = NSDate(ISO8601String: iso8601date) else {
            return "Hot Zone"
        }
        
        let durationFormatter = NSDateComponentsFormatter()
        durationFormatter.unitsStyle = .Short
        durationFormatter.allowedUnits = [.Day, .Hour, .Minute]
        
        let duration = NSDate().timeIntervalSinceDate(date)
        
        let durationString = durationFormatter.stringFromTimeInterval(duration)!
        
        return "Hot Zone - \(durationString) ago"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
