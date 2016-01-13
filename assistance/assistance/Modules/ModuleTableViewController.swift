//
//  ModuleTableViewController.swift
//  assistance
//
//  Created by Nicko on 03/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class ModuleTableViewController: UITableViewController {

    var availableModules = [AnyObject]()
    var activatedModules: [String]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let availableModules = NSUserDefaults.standardUserDefaults().objectForKey("availableModules") as? [AnyObject] {
            self.availableModules = availableModules
        }
        
        if let activatedModules = NSUserDefaults.standardUserDefaults().objectForKey("activatedModules") as? [String] {
            self.activatedModules = activatedModules
        }
        
        loadModules()
    }
    
    func loadModules() {
        ModuleManager().availableModules {
            result in
            
            do {
                let data = try result()
                if let dataString = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) where dataString.length > 0,
                    let modules = try? NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableLeaves) as? NSArray {
                        
                        self.availableModules = modules as! [AnyObject]
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
//                        NSUserDefaults.standardUserDefaults().setObject(self.availableModules, forKey: "availableModules")
                }
            } catch {
                //                switch error {
                //                case ModuleManager.Error.NotAuthenticated:
                //                    print("Not Authenticated!")
                //                default:
                //                    break
                //                }
            }
        }
        
        ModuleManager().activatedModules {
            result in
            
            do {
                let data = try result()
                if let dataString = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) where dataString.length > 0,
                    let modules = try? NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableLeaves) as? NSArray {
                        
                        self.activatedModules = modules as? [String]
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
//                        NSUserDefaults.standardUserDefaults().setObject(self.activatedModules, forKey: "activatedModules")
                }
            } catch { }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableModules.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ModuleCell", forIndexPath: indexPath) as! ModuleTableViewCell

        let module = availableModules[indexPath.row] as! [String: AnyObject]
        let id = module["id"] as! String
        let name = module["name"] as! String
        let description = module["descriptionShort"] as! String
        let logoURLString = module["logoUrl"] as! String
        
        cell.moduleID = id
        cell.nameLabel.text = name
        cell.descriptionLabel.text = description
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let logoURL = NSURL(string: logoURLString)
            let logoData = NSData(contentsOfURL: logoURL!)
            
            if let logoData = logoData {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.logoImageView.image = UIImage(data: logoData)
                }
            }
        }
        
        if let activatedModules = activatedModules {
            cell.moduleSwitch.enabled = true
            cell.moduleSwitch.on = activatedModules.contains(id)
        }
        
        cell.tableViewController = self

        return cell
    }
    
    // MARK: - Storyboard segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showModule" {
            let destinationViewController = segue.destinationViewController as! ModuleDetailTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                destinationViewController.moduleData = availableModules[indexPath.row] as! [String: AnyObject]
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
