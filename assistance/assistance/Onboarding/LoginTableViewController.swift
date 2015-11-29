//
//  LoginTableViewController.swift
//  Labels
//
//  Created by Nicko on 30/07/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import Locksmith

class LoginTableViewController: UITableViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        if let userEmail = NSUserDefaults.standardUserDefaults().stringForKey("UserEmail") {
            let dictionary = Locksmith.loadDataForUserAccount(userEmail)
            if let dictionary = dictionary, let password = dictionary["password"] as? String {
                self.emailTextField.text = userEmail
                self.passwordTextField.text = password
                signIn(self)
            }
        }
    }
    
    @IBAction func signIn(sender: AnyObject) {
        UserManagement().login(emailTextField.text!, password: passwordTextField.text!) {
            (succeeded: Bool, message: String) -> () in
            
            if !succeeded {
                let alertController = UIAlertController(title: "Login failed", message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            } else {
                NSUserDefaults.standardUserDefaults().setObject(self.emailTextField.text, forKey: "UserEmail")
                
                _ = try? Locksmith.updateData(["password": self.passwordTextField.text!, "token": message], forUserAccount: self.emailTextField.text!)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

}
