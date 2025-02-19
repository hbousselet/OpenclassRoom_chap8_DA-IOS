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
    
    func getSleepsAsync() async throws -> [Sleep]? {
        await viewContext.perform {
            let request: NSFetchRequest = NSFetchRequest<Sleep>(entityName: "Sleep")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            do {
                let fetchResult = try self.viewContext.fetch(request)
                return fetchResult
            } catch let error as NSError {
                print("Erreur pour récupérer les données de sommeil : \(error), \(error.userInfo)")
                return nil
            }
        }
    }
}
