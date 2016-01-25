//
//  ModuleTableViewCell.swift
//  assistance
//
//  Created by Nicko on 03/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class ModuleTableViewCell: UITableViewCell {

    @IBOutlet var logoImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var moduleSwitch: UISwitch!
    
    var tableViewController: ModuleTableViewController?
    
    var moduleID = ""
    var moduleData = [String: AnyObject]()
    
    @IBAction func switchModule(sender: UISwitch) {
        if sender.on {
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let moduleActivationController = self.tableViewController?.storyboard?.instantiateViewControllerWithIdentifier("ModuleActivationController") as! UINavigationController
            let moduleActivationTableViewController = moduleActivationController.topViewController as! ModuleActivationTableViewController
            moduleActivationTableViewController.moduleData = moduleData
            moduleActivationTableViewController.requiredSensors = moduleData["requiredCapabilities"] as! [[String: AnyObject]]
            moduleActivationTableViewController.optionalSensors = moduleData["optionalCapabilites"] as! [[String: AnyObject]]
            
            self.tableViewController?.presentViewController(moduleActivationController, animated: true, completion: nil)
            
        } else {
            ModuleManager().deactivateModule(self.moduleID) {
                result in
                
                do {
                    let _ = try result()
                } catch {
                    sender.on = true
                }
                self.tableViewController?.loadModules()
            }
        }
    }
    
}
