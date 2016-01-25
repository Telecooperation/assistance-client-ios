//
//  ModuleActivationTableViewController.swift
//  assistance
//
//  Created by Nicko on 03/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import SVProgressHUD

class ModuleActivationTableViewController: UITableViewController {

    var moduleData = [String: AnyObject]()
    
    var requiredSensors = [[String: AnyObject]]() {
        didSet {
            requiredSensors = requiredSensors.filter { SensorsManager().sensorManagerForType($0["type"] as! String) != nil }
            for sensor in requiredSensors {
                if let sensorType = sensor["type"] as? String, sensorManager = SensorsManager().sensorManagerForType(sensorType) where sensorManager.needsAuthorization() {
                    self.sensorsToAuthorize.append(sensorType)
                }
            }
        }
    }
    var optionalSensors = [[String: AnyObject]]() {
        didSet {
            optionalSensors = optionalSensors.filter { SensorsManager().sensorManagerForType($0["type"] as! String) != nil }
            for sensor in optionalSensors {
                if let sensorType = sensor["type"] as? String, sensorManager = SensorsManager().sensorManagerForType(sensorType) where sensorManager.needsAuthorization() {
                    self.sensorsToAuthorize.append(sensorType)
                }
            }
        }
    }
    
    var sensorsToAuthorize = [String]()
    var sensorsToDenyAuthorization = [String]()
    var activated = false
    var sensorPermissionMissing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dismissIfActivatedAndAuthorized()
    }
    
    @IBAction func activate(sender: AnyObject) {
        activated = true
        
        for sensorType in sensorsToDenyAuthorization {
            if let sensorManager = SensorsManager().sensorManagerForType(sensorType) where !sensorManager.needsAuthorization() {
                sensorManager.denyAuthorization()
            }
        }
        
        for sensorType in sensorsToAuthorize {
            if let sensorManager = SensorsManager().sensorManagerForType(sensorType) where sensorManager.needsAuthorization() {
                sensorManager.requestAuthorizationFromViewController(self) {
                    granted, error in
                    
                    if granted {
                        if let index = self.sensorsToAuthorize.indexOf(sensorType) {
                            self.sensorsToAuthorize.removeAtIndex(index)
                        }
                    } else {
                        self.sensorPermissionMissing = true
                    }
                    self.dismissIfActivatedAndAuthorized()
                }
            }
        }
        self.dismissIfActivatedAndAuthorized()
    }
    
    func dismissIfActivatedAndAuthorized() {
        if activated {
            if sensorsToAuthorize.count == 0 {
//                SVProgressHUD.setDefaultStyle(.Dark)
                SVProgressHUD.show()
                ModuleManager().activateModule(self.moduleData["id"] as! String) {
                    _ in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        SVProgressHUD.dismiss()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            } else if self.sensorPermissionMissing {
                let alertController = UIAlertController(title: "Activation failed", message: "Module could not be authorized because of missing Sensor Permissions", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) {
                    action in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                alertController.addAction(cancelAction)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 1
            case 1: return requiredSensors.count
            case 2: return optionalSensors.count
            default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "Module Information"
            case 1: return "Required Sensors"
            case 2: return "Optional Sensors"
            default: return ""
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ModuleActivationInformationTableViewCell), forIndexPath: indexPath) as! ModuleActivationInformationTableViewCell
            
            let name = moduleData["name"] as! String
            let description = moduleData["descriptionLong"] as! String
            let logoURLString = moduleData["logoUrl"] as! String
            
            cell.moduleID = moduleData["id"] as! String
            cell.nameLabel.text = name
            cell.descriptionLabel.text = description
            
            if let logoURL = NSURL(string: logoURLString) {
                cell.logoImageView.sd_setImageWithURL(logoURL)
            }
            
            cell.tableViewController = self
            
            return cell
        } else if indexPath.section == 1 {
            guard let sensorType = requiredSensors[indexPath.row]["type"] as? String, sensorManager = SensorsManager().sensorManagerForType(sensorType) else {
                return UITableViewCell()
            }
            
            var cell = tableView.dequeueReusableCellWithIdentifier(String(ModuleActivationSensorTableViewCell), forIndexPath: indexPath) as! ModuleActivationSensorTableViewCell
//            let usedByModules = sensorManager.usedByModules()
//            if usedByModules.count > 0 {
//                cell = tableView.dequeueReusableCellWithIdentifier(String(ModuleActivationUsedSensorTableViewCell), forIndexPath: indexPath) as! ModuleActivationUsedSensorTableViewCell
//                (cell as! ModuleActivationUsedSensorTableViewCell).usedByLabel.text = "Used by \(usedByModules.map({ ModuleManager().nameForModuleWithID($0)! }).joinWithSeparator(", "))"
//            }
            
            cell.sensorType = sensorType
            cell.tableViewController = self
            
            cell.statusSwitch.enabled = false
            
            cell.configureCell()
            
            return cell
        } else if indexPath.section == 2 {
            guard let sensorType = optionalSensors[indexPath.row]["type"] as? String, sensorManager = SensorsManager().sensorManagerForType(sensorType) else {
                return UITableViewCell()
            }
            
            var cell = tableView.dequeueReusableCellWithIdentifier(String(ModuleActivationSensorTableViewCell), forIndexPath: indexPath) as! ModuleActivationSensorTableViewCell
            
            cell.statusSwitch.enabled = true
            
            let usedByModules = sensorManager.usedByModules()
            if usedByModules.count > 0 {
                cell = tableView.dequeueReusableCellWithIdentifier(String(ModuleActivationUsedSensorTableViewCell), forIndexPath: indexPath) as! ModuleActivationUsedSensorTableViewCell
                (cell as! ModuleActivationUsedSensorTableViewCell).usedByLabel.text = "Used by \(usedByModules.map({ ModuleManager().nameForModuleWithID($0)! }).joinWithSeparator(", "))"
                cell.statusSwitch.enabled = false
            }
            
            cell.sensorType = sensorType
            cell.tableViewController = self
            
            cell.configureCell()
            
            return cell
        }
        
        return UITableViewCell()
    }

}
