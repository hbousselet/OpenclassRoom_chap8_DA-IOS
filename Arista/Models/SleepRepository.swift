//
//  SleepRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class SleepRepository {
    
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func get() async throws -> [Sleep] {
        try await viewContext.perform {
            let request: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sleep")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return try self.viewContext.fetch(request) as? [Sleep] ?? []
        }
    }
}
