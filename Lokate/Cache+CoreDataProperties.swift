//
//  Cache+CoreDataProperties.swift
//  Lokate
//
//  Created by Colben Matthew Kharrl on 4/17/17.
//  Copyright © 2017 ASU. All rights reserved.
//

import Foundation
import CoreData


extension Cache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged public var title: String?
    @NSManaged public var summary: String?
    @NSManaged public var feature: String?
    @NSManaged public var url: String?
    @NSManaged public var thumbnail: NSData?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var added: NSDate?

}
