//
//  RegisterTableViewController.swift
//  Labels
//
//  Created by Nicko on 30/07/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import Locksmith

class RegisterTableViewController: UITableViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func register(sender: AnyObject) {
        UserManagement().register(emailTextField.text!, password: passwordTextField.text!) {
            (succeeded: Bool, message: String) -> () in
            
            if !succeeded {
                let alertController = UIAlertController(title: "Registration failed", message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            } else {
                NSUserDefaults.standardUserDefaults().setObject(self.emailTextField.text, forKey: "UserEmail")
                
                _ = try? Locksmith.updateData(["password": self.passwordTextField.text!], forUserAccount: self.emailTextField.text!)

                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
