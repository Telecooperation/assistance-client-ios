//
//  ModuleActivationInformationTableViewCell.swift
//  assistance
//
//  Created by Nicko on 21/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class ModuleActivationInformationTableViewCell: UITableViewCell {

    @IBOutlet var logoImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var tableViewController: ModuleActivationTableViewController?
    var moduleID = ""

}
