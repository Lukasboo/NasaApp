//
//  Sonda+CoreDataProperties.swift
//  Nasa App
//
//  Created by Lucas Daniel on 23/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation
import CoreData

extension Sonda {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sonda> {
        return NSFetchRequest<Sonda>(entityName: "Sonda")
    }
    
    @NSManaged public var sondaName: String?
}

// MARK: Generated accessors for photos
extension Sonda {
    
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
    
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)
    
    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)
    
    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
    
}
