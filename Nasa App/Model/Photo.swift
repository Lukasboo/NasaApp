//
//  Photo.swift
//  Nasa App
//
//  Created by Lucas Daniel on 23/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    static let name = "Photo"
    
    convenience init(earth_date: String, img_src: String, forSonda: Sonda, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Photo.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.earth_date = earth_date            
            self.img_src = img_src
            self.sonda = forSonda
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
