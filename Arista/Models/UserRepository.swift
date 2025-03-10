//
//  UserRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class UserRepository {
    let viewContext: NSManagedObjectContext
        
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func get() async throws -> [User] {
        try await viewContext.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "User")
            request.fetchLimit = 1
            return try self.viewContext.fetch(request) as? [User] ?? []
        }
    }
}
