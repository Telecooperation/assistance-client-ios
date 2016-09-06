//
//  ModuleTableViewController.swift
//  assistance
//
//  Created by Nicko on 03/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class ModuleTableViewController: UITableViewController {

    var availableModules = [[String: AnyObject]]() {
        didSet {
            availableModules = availableModules.sort { ($0["name"] as! String) < ($1["name"] as! String) }
        }
    }
    var activatedModules = [String]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let archivedAvailableModules = NSUserDefaults.standardUserDefaults().objectForKey("availableModules") as? NSData,
        availableModules = NSKeyedUnarchiver.unarchiveObjectWithData(archivedAvailableModules) as? [[String: AnyObject]] {
                self.availableModules = availableModules
        }
        
        if let archivedActivatedModules = NSUserDefaults.standardUserDefaults().objectForKey("activatedModules") as? NSData,
            activatedModules = NSKeyedUnarchiver.unarchiveObjectWithData(archivedActivatedModules) as? [String] {
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
                    let modules = try? NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableContainers) as! [[String: AnyObject]] {
                        
                        self.availableModules = modules
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                        
                        let archivedAvailableModules = NSKeyedArchiver.archivedDataWithRootObject(self.availableModules)
                        NSUserDefaults.standardUserDefaults().setObject(archivedAvailableModules, forKey: "availableModules")
                        
                        var moduleNames = [String: String]()
                        for module: [String: AnyObject] in modules {
                            moduleNames[module["id"] as! String] = module["name"] as? String
                        }
                        NSUserDefaults.standardUserDefaults().setObject(moduleNames, forKey: "moduleNames")
                }
            } catch { }
        }
        
        ModuleManager().activatedModules {
            result in
            
            do {
                let data = try result()
                if let dataString = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding) where dataString.length > 0,
                    let modules = try? NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .MutableLeaves) as? NSArray {
                        
                        self.activatedModules = modules as! [String]
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                        
                        let archivedActivatedModules = NSKeyedArchiver.archivedDataWithRootObject(self.activatedModules)
                        NSUserDefaults.standardUserDefaults().setObject(archivedActivatedModules, forKey: "activatedModules")
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

        let module = availableModules[indexPath.row] 
        let id = module["id"] as! String
        let name = module["name"] as! String
        let description = module["descriptionShort"] as! String
        let logoURLString = module["logoUrl"] as! String
        
        cell.moduleData = module
        cell.moduleID = id
        cell.nameLabel.text = name
        cell.descriptionLabel.text = description
        
        if let logoURL = NSURL(string: logoURLString) {
            cell.logoImageView.sd_setImageWithURL(logoURL)
        }
        
        cell.moduleSwitch.enabled = true
        cell.moduleSwitch.on = activatedModules.contains(id)
        
        cell.tableViewController = self

        return cell
    }
    
    // MARK: - Storyboard segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showModule" {
            let destinationViewController = segue.destinationViewController as! ModuleActivationTableViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let moduleData = availableModules[indexPath.row] 
                destinationViewController.moduleData = moduleData
                
                destinationViewController.requiredSensors = moduleData["requiredCapabilities"] as! [[String: AnyObject]]
                destinationViewController.optionalSensors = moduleData["optionalCapabilites"] as! [[String: AnyObject]]
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
