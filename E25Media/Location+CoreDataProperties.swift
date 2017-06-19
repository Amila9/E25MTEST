//
//  Location+CoreDataProperties.swift
//  E25Media
//
//  Created by Amila on 5/25/17.
//  Copyright © 2017 amila. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var img: String?
    @NSManaged public var lat: String?
    @NSManaged public var long: String?
    @NSManaged public var name: String?

}
