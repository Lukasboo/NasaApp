//
//  Photo+CoreDataProperties.swift
//  Nasa App
//
//  Created by Lucas Daniel on 23/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    
    @NSManaged public var earth_date: String?
    @NSManaged public var img_src: String?
    @NSManaged public var sonda: Sonda?
    
}
