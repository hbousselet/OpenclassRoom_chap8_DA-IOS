//
//  SleepRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class SleepRepository {
    private var viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func getSleeps() throws -> [Sleep] {
        let request: NSFetchRequest = NSFetchRequest<Sleep>(entityName: "Sleep")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return try viewContext.fetch(request)
    }
    
    func getSleepsAsync() async throws -> [Sleep] {
        try await viewContext.perform {
            let request: NSFetchRequest = NSFetchRequest<Sleep>(entityName: "Sleep")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            guard let fetchResult = try? self.viewContext.fetch(request) else {
                throw PrivError.notEnoughPrivileges
            }
            return fetchResult
        }
    }
}
