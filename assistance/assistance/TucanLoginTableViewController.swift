//
//  TucanLoginTableViewController.swift
//  assistance
//
//  Created by Nicko on 02/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

import RealmSwift

class TucanLoginTableViewController: UITableViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    let realm = try! Realm()
    
    @IBAction func signIn(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            _ = try? self.realm.write {
                self.realm.add(Tucan(username: self.usernameTextField.text!, password: self.passwordTextField.text!))
            }
        })
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
