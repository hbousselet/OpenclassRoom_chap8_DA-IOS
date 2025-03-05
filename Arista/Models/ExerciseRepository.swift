//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class ExerciseRepository {
    
    typealias T = Exercise
    
    let viewContext: NSManagedObjectContext

    init?(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func get() async throws -> [Exercise] {
        try await viewContext.perform {
            let request: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Exercise")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return try self.viewContext.fetch(request) as? [Exercise] ?? []
        }
    }
    
    func save(category: String,
                           duration: Int,
                           intensity: Int,
                           startDate: Date) async throws {
        await viewContext.perform {
            let exercice = Exercise(context: self.viewContext)
            exercice.startDate = startDate
            exercice.category = category
            exercice.intensity = Int64(intensity)
            exercice.duration = Int64(duration)
            do {
                try self.viewContext.save()
            } catch let error as NSError {
                print("Erreur lors de l'enregistrement du contexte : \(error), \(error.userInfo)")
            }
        }
    }
    
    func delete(exercises: [Exercise]) async {
        await viewContext.perform {
            for exercise in exercises {
                self.viewContext.delete(exercise)
            }
        }
    }
}
