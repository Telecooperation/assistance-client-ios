//
//  SensorPermissionsTableViewController.swift
//  assistance
//
//  Created by Nicko on 08/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class SensorPermissionsTableViewController: UITableViewController {

    var sensorTypes = SensorsManager().allSensorTypes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorTypes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sensorType = sensorTypes[indexPath.row]
        guard let sensorManager = SensorsManager().sensorManagerForType(sensorType) else {
            return UITableViewCell()
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier(String(SensorPermissionsSensorTableViewCell), forIndexPath: indexPath) as! SensorPermissionsSensorTableViewCell
        
        let requiredByModules = sensorManager.requiredByModules()
        let usedByModules = Array(Set(sensorManager.usedByModules()).subtract(Set(requiredByModules)))
        if requiredByModules.count + usedByModules.count > 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(String(SensorPermissionsUsedSensorTableViewCell), forIndexPath: indexPath) as! SensorPermissionsUsedSensorTableViewCell
            
            var usedString = [String]()
            if requiredByModules.count > 0 {
                usedString.append("Required by \(requiredByModules.map({ ModuleManager().nameForModuleWithID($0)! }).joinWithSeparator(", ")).")
            }
            if usedByModules.count > 0 {
                usedString.append("Used by \(usedByModules.map({ ModuleManager().nameForModuleWithID($0)! }).joinWithSeparator(", ")).")
            }
            (cell as! SensorPermissionsUsedSensorTableViewCell).usedByLabel.text = usedString.joinWithSeparator(" ")
            
            cell.requiredByModules = requiredByModules
            cell.usedByModules = usedByModules
        }
        
        cell.sensorType = sensorType
        cell.tableViewController = self
        
        cell.configureCell()
        
        return cell
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
