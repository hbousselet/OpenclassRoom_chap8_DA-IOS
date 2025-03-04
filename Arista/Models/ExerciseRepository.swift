//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class ExerciseRepository: Repository {
    
    typealias T = Exercise
    
    let viewContext: NSManagedObjectContext

    init?(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func get<T>() async throws -> [T]? {
        await viewContext.perform {
            let request: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Exercise")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            do {
                let fetchResult = try self.viewContext.fetch(request)
                return fetchResult as? [T]
            } catch let error as NSError {
                print("Erreur pour récupérer les exercices : \(error), \(error.userInfo)")
                return nil
            }
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
    
    func deleteAsync(exercises: [Exercise]) async {
        await viewContext.perform {
            for exercise in exercises {
                self.viewContext.delete(exercise)
            }
        }
    }
}
