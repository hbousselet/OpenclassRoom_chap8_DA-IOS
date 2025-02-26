//
//  UserRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class UserRepository: Repository {
    let viewContext: NSManagedObjectContext
    
    typealias T = User
    
    init?(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func getAsync<T>() async throws -> [T]? {
        await viewContext.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "User")
            request.fetchLimit = 1
            do {
                let fetchResult = try self.viewContext.fetch(request)
                return fetchResult as? [T]
            } catch let error as NSError {
                print("Erreur pour récupérer les données utilisateur : \(error), \(error.userInfo)")
                return nil
            }
        }
    }
}
