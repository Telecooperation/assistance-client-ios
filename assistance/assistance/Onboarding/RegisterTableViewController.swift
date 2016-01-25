//
//  RegisterTableViewController.swift
//  Labels
//
//  Created by Nickolas Guendling on 30/07/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import UIKit

class RegisterTableViewController: UITableViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var acceptedTerms = false
    
    @IBAction func register(sender: AnyObject) {
        if acceptedTerms {
            UserManager().register(emailTextField.text!, password: passwordTextField.text!) {
                result in
                
                do {
                    let _ = try result()
                    
                    NSUserDefaults.standardUserDefaults().setObject(self.emailTextField.text, forKey: "UserEmail")
                    NSUserDefaults.standardUserDefaults().setObject(self.passwordTextField.text, forKey: "UserPassword")
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } catch ServerConnection.Error.RequestError(let errorCode) {
                
                    var errorMessage = "An unknown error occured."
                    if let message = ServerConnection.errorMessage[errorCode] {
                        errorMessage = message
                    }
                    
                    let alertController = UIAlertController(title: "Registration failed", message: errorMessage, preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                
                } catch { }
            }
        } else {
            let alertController = UIAlertController(title: "Terms of Service", message: "You have to accept the Terms of Service to register", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alertController, animated: true, completion: nil)
            })
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTerms" {
            (sender as! UITableViewCell).accessoryType = .Checkmark
            acceptedTerms = true
        }
    }
    
}
