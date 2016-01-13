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
    
    @IBAction func switchModule(sender: UISwitch) {
        if sender.on {
            ModuleManager().activateModule(self.moduleID) {
                result in
                
                do {
                    let _ = try result()
                } catch {
                    sender.on = false
                }
                self.tableViewController?.loadModules()
            }
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
