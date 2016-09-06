//
//  UIGestureRecognizer+Closure.swift
//  assistance
//
//  Created by Nicko on 19/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import UIKit

// Global array of targets, as extensions cannot have non-computed properties
private var target = [Target]()

extension UIGestureRecognizer {
    
    convenience init(trailingClosure closure: (() -> ())) {
        // let UIGestureRecognizer do its thing
        self.init()
        
        target.append(Target(closure))
        self.addTarget(target.last!, action: "invoke")
    }
}

private class Target {
    
    // store closure
    private var trailingClosure: (() -> ())
    
    init(_ closure:(() -> ())) {
        trailingClosure = closure
    }
    
    // function that gesture calls, which then
    // calls closure
    /* Note: Note sure why @IBAction is needed here */
    @IBAction func invoke() {
        trailingClosure()
    }
}