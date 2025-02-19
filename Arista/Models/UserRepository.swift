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
        await viewContext.perform {
            let request = NSFetchRequest<User>(entityName: "User")
            request.fetchLimit = 1
            do {
                let fetchResult = try self.viewContext.fetch(request).first
                return fetchResult
            } catch let error as NSError {
                print("Erreur pour récupérer les données utilisateur : \(error), \(error.userInfo)")
                return nil
            }
        }
    }
}
