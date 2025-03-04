//
//  SleepRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class SleepRepository: Repository {
    typealias T = Sleep
    
    let viewContext: NSManagedObjectContext

    init?(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func get<T>() async throws -> [T]? {
        await viewContext.perform {
            let request: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sleep")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            do {
                let fetchResult = try self.viewContext.fetch(request)
                return fetchResult as? [T]
            } catch let error as NSError {
                print("Erreur pour récupérer les données de sommeil : \(error), \(error.userInfo)")
                return nil
            }
        }
    }
}
