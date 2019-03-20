//
//  HandlePhoto.swift
//  Nasa App
//
//  Created by Lucas Daniel on 20/03/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation
import CoreData

class HandlePhoto {
    
    func fetchPhotos(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil, viewContext: NSManagedObjectContext) throws -> [Photo]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let photos = try viewContext.fetch(fr) as? [Photo] else {
            return nil
        }
        return photos
    }
    
}
