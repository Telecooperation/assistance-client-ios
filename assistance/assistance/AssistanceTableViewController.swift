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

    var currentInformation = [[String: AnyObject]]() // = [
//        ["moduleId": "de.tudarmstadt.informatik.tk.assistanceplatform.modules.hotplaces",
//         "created": "2015-11-29T20:21:34+01:00",
//         "content":
//            ["type": "group", "alignment": "vertical", "content": [
//                    ["type": "group", "alignment": "horizontal", "target": "http://news.ycombinator.com", "content": [
//                            ["type": "text", "style": "headline", "caption": "This Is an Awesome Headline!", "priority": 3],
//                            ["type": "text", "style": "footnote", "caption": "Yeah.", "alignment": "right", "highlighted": true]
//                        ]
//                    ],
//                    ["type": "map", "showUserLocation": true, "points": [[49.877427, 8.653879], [49.877496, 8.653429], [49.877220, 8.653493]]],
//                    ["type": "image", "source": "https://www.tu-darmstadt.de/media/illustrationen/die_universitaet/medien_ausstellung/bilder_geschichte/7_das_logo_der_tu_darmstadt_/01-Das-Logo-der-TU-Darmstadt.jpg"],
//                    ["type": "button", "caption": "Go to the Apple website!", "target": "http://www.apple.com"]
//                ]
//            ]
//        ]
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 290.0
    }
    
    @IBAction func refresh(sender: AnyObject) {
        ModuleManager().currentInformation {
            result in
            
            do {
                let data = try result()
                if let dataString = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) where dataString.length > 0 {
                    if let currentInformation = try? NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableContainers) as! [[String: AnyObject]] {
                        self.currentInformation = currentInformation
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        })
                    }
                }
            } catch {
                
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            performSegueWithIdentifier("locationAuthorizationSegue", sender: self)
        } else if CLLocationManager.authorizationStatus() == .Denied || CLLocationManager.authorizationStatus() == .Restricted {
            performSegueWithIdentifier("locationAuthorizationFailedSegue", sender: self)
        } else if let _ = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail") {
            DataSync().syncData()
            refresh(self)
        } else {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return currentInformation.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        CardParser.sharedParser.tableViewController = self
        
        let stackView = UIStackView()
        stackView.axis = .Vertical
        
        let cardInfo = currentInformation[Int(indexPath.section)]
        if let content = cardInfo["content"] as? [String: AnyObject] {
                CardParser.sharedParser.parseObject(content, superview: stackView)
        }
            
        cell.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[stackView]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["stackView": stackView])
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[stackView]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["stackView": stackView])
        cell.contentView.addConstraints(horizontalConstraints + verticalConstraints)

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let cardInfo = currentInformation[section]
        
        var moduleName = ""
        if let moduleNames = NSUserDefaults.standardUserDefaults().objectForKey("moduleNames") as? [String: String], moduleID = cardInfo["moduleId"] as? String, name = moduleNames[moduleID] {
            moduleName = name
        }
        
        let iso8601date = currentInformation[section]["created"] as! String
        guard let date = NSDate(ISO8601String: iso8601date) else {
            return moduleName
        }
        
        let durationFormatter = NSDateComponentsFormatter()
        durationFormatter.unitsStyle = .Short
        durationFormatter.allowedUnits = [.Day, .Hour, .Minute]
        
        let duration = NSDate().timeIntervalSinceDate(date)
        
        let durationString = durationFormatter.stringFromTimeInterval(duration)!
        
        return "\(moduleName) - \(durationString) ago"
    }

}
