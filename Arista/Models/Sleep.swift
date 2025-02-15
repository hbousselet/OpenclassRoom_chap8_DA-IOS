//
//  Sleep.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 15/02/2025.
//

import Foundation
import CoreData

extension Sleep {

    static func getSleeps(context: NSManagedObjectContext) throws -> [Sleep] {
        let request: NSFetchRequest = NSFetchRequest<Sleep>(entityName: "Sleep")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return try context.fetch(request)
    }
    
}
