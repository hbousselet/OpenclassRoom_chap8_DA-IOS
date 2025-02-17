//
//  UserRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class UserRepository {
    private var viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func getUser() throws -> User? {
        let request = NSFetchRequest<User>(entityName: "User")
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }
    
    func getUserAsync() async throws -> User? {
        try await viewContext.perform {
            let request = NSFetchRequest<User>(entityName: "User")
            request.fetchLimit = 1
            guard let fetchResult = try? self.viewContext.fetch(request).first else {
                throw PrivError.notEnoughPrivileges
            }
            return fetchResult
        }
    }
}

enum PrivError: Error {
    case notEnoughPrivileges
}
