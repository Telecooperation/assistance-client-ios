//
//  ResultsExtension.swift
//  Labels
//
//  Created by Nickolas Guendling on 12/10/15.
//  Copyright © 2015 Darmstadt University of Technology. All rights reserved.
//

import Foundation

import RealmSwift

extension Results {
    func toArray() -> [Results.Generator.Element] {
        return map { $0 }
    }
}