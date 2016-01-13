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
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorTypes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SensorPermissionsCell", forIndexPath: indexPath) as! SensorPermissionsTableViewCell

        cell.sensorType = sensorTypes[indexPath.row]
        cell.tableViewController = self
        
        cell.configureCell()

        return cell
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
