//
//  User.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 15/02/2025.
//

import Foundation
import CoreData


extension User {
    
    static func getUser(context: NSManagedObjectContext) throws -> User? {
        let request = NSFetchRequest<User>(entityName: "User")
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
