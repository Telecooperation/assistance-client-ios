//
//  SensorPermissionsTableViewCell.swift
//  assistance
//
//  Created by Nicko on 09/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class SensorPermissionsTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusSwitch: UISwitch!
    
    var sensorType: String?
    var sensorManager: SensorManager?
    
    var tableViewController: UITableViewController?

    func configureCell() {
        if let sensorType = sensorType, sensorManager = SensorsManager().sensorManagerForType(sensorType) {
            self.sensorManager = sensorManager
            
            nameLabel.text = sensorManager.name()
            statusSwitch.on = !sensorManager.needsAuthorization()
        }
    }

    @IBAction func changeStatus(sender: AnyObject) {
        if let sensorManager = sensorManager, tableViewController = tableViewController {
            if sensorManager.needsAuthorization() {
                sensorManager.requestAuthorizationFromViewController(tableViewController) {
                    granted, error in
                    
                    if !granted {
                        self.statusSwitch.on = false
                    }
                }
            } else {
                sensorManager.denyAuthorization()
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
