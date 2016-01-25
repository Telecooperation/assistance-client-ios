//
//  SensorPermissionsTableViewCell.swift
//  assistance
//
//  Created by Nicko on 09/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class SensorPermissionsSensorTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusSwitch: UISwitch!
    
    var sensorType: String?
    var sensorManager: SensorManager?
    
    var tableViewController: UITableViewController?
    
    var requiredByModules = [String]()
    var usedByModules = [String]()

    func configureCell() {
        if let sensorType = sensorType, sensorManager = SensorsManager().sensorManagerForType(sensorType) {
            self.sensorManager = sensorManager
            
            nameLabel.text = sensorManager.name()
            statusSwitch.on = !sensorManager.needsAuthorization()
        }
    }

    @IBAction func changeStatus(sender: AnyObject) {
        if let sensorManager = sensorManager, tableViewController = tableViewController {
            if statusSwitch.on {
                if sensorManager.needsAuthorization() {
                    sensorManager.requestAuthorizationFromViewController(tableViewController) {
                        granted, error in
                        
                        if !granted {
                            self.statusSwitch.on = false
                        }
                    }
                }
            } else {
                if requiredByModules.count == 0 {
                    sensorManager.denyAuthorization()
                } else {
                    let deactivatedModules = requiredByModules.map({ ModuleManager().nameForModuleWithID($0)! }).joinWithSeparator(", ")
                    let alertController = UIAlertController(title: "Really deactivate?", message: "If you deny the permission to use this sensor, these modules will be deactivated: \(deactivatedModules). Do you really want to deactivate them?", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
                        action in
                        
                        self.statusSwitch.on = true
                    }
                    let deactivateAction = UIAlertAction(title: "Deactivate", style: .Destructive) {
                        action in
                        
                        for module in self.requiredByModules {
                            ModuleManager().deactivateModule(module) {
                                result in
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    tableViewController.tableView.reloadData()
                                }
                            }
                        }
                        sensorManager.denyAuthorization()
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(deactivateAction)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        tableViewController.presentViewController(alertController, animated: true, completion: nil)
                    })

                }
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
