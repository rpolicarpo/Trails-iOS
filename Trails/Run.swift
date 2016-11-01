//
//  Run.swift
//  Trails
//
//  Created by Rui Policarpo on 03/04/16.
//  Copyright © 2016 nExp. All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var locations: NSOrderedSet
    @NSManaged var trailRef: NSString
    @NSManaged var trailCode: NSString
    @NSManaged var trailName: NSString
    @NSManaged var points: Double
    @NSManaged var overlays: NSArray
}
