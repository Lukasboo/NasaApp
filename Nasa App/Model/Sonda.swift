//
//  Sonda.swift
//  Nasa App
//
//  Created by Lucas Daniel on 23/02/19.
//  Copyright © 2019 Lucas Daniel. All rights reserved.
//

import Foundation
import CoreData

@objc(Sonda)
public class Sonda: NSManagedObject {
    
    static let name = "Sonda"
    
    convenience init(sondaName: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Sonda.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.sondaName = sondaName
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
