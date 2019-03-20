//
//  HandleSonda.swift
//  Nasa App
//
//  Created by Lucas Daniel on 20/03/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation
import CoreData

class HandleSonda {
    
    func fetchAllSondas(_ predicate: NSPredicate? = nil, entityName: String, sorting: NSSortDescriptor? = nil, viewContext: NSManagedObjectContext) throws -> [Sonda]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let sonda = try viewContext.fetch(fr) as? [Sonda] else {
            return nil
        }
        return sonda
    }
    
   
}
