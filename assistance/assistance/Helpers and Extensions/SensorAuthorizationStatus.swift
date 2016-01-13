//
//  SensorAuthorizationStatus.swift
//  assistance
//
//  Created by Nicko on 13/01/16.
//  Copyright © 2016 Darmstadt University of Technology. All rights reserved.
//

import Foundation

enum SensorAuthorizationStatus: Int {
    case Granted, Denied, NeedsSystemAuthorization, SystemAuthorizationDenied
}