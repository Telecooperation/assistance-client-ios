//
//  ModuleActivationSensorTableViewCell.swift
//  assistance
//
//  Created by Nicko on 21/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class ModuleActivationSensorTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusSwitch: UISwitch!
    
    var sensorType: String?
    var sensorManager: SensorManager?
    
    var tableViewController: ModuleActivationTableViewController?
    
    func configureCell() {
        if let sensorType = sensorType, sensorManager = SensorsManager().sensorManagerForType(sensorType), tableViewController = tableViewController {
            self.sensorManager = sensorManager
            
            nameLabel.text = sensorManager.name()
            statusSwitch.on = true
            
            if sensorManager.needsAuthorization() {
                statusSwitch.onTintColor = UIColor.flatYellowColor()
            } else {
                statusSwitch.onTintColor = UIColor.flatRedColor()
            }
            
            if sensorManager.needsAuthorization() && tableViewController.sensorsToAuthorize.indexOf(sensorType) == nil {
                statusSwitch.on = false
            }
        }
    }
    
    @IBAction func changeStatus(sender: AnyObject) {
        if let sensorType = sensorType, sensorManager = sensorManager, tableViewController = tableViewController {
            if sensorManager.needsAuthorization() {
                if statusSwitch.on {
                    tableViewController.sensorsToAuthorize.append(sensorType)
                } else if let index = tableViewController.sensorsToAuthorize.indexOf(sensorType) {
                    tableViewController.sensorsToAuthorize.removeAtIndex(index)
                }
            } else {
                if !statusSwitch.on {
                    tableViewController.sensorsToDenyAuthorization.append(sensorType)
                } else if let index = tableViewController.sensorsToDenyAuthorization.indexOf(sensorType) {
                    tableViewController.sensorsToDenyAuthorization.removeAtIndex(index)
                }
            }
        }
    }

}
