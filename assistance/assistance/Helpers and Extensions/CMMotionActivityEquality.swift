//
//  CMMotionActivityExtension.swift
//  Labels
//
//  Created by Nickolas Guendling on 14/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import CoreMotion

func == (lhs: CMMotionActivity, rhs: CMMotionActivity) -> Bool {
    return lhs.unknown == rhs.unknown && lhs.stationary == rhs.stationary && lhs.walking == rhs.walking && lhs.running == rhs.running && lhs.automotive == rhs.automotive && lhs.cycling == rhs.cycling && lhs.confidence == rhs.confidence
}