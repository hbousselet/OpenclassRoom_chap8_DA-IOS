//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 17/02/2025.
//

import Foundation
import CoreData

class ExerciseRepository {
    private var viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func getExercises() throws -> [Exercise] {
        let request: NSFetchRequest = NSFetchRequest<Exercise>(entityName: "Exercise")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return try viewContext.fetch(request)
    }
    
    func saveExercise(category: String,
                      duration: Int,
                      intensity: Int,
                      startDate: Date) throws {
        let exercice = Exercise(context: viewContext)
        exercice.category = category
        exercice.startDate = startDate
        exercice.intensity = Int64(intensity)
        exercice.duration = Int64(duration)
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Erreur lors de l'enregistrement du contexte : \(error), \(error.userInfo)")
        }
    }
    
    func delete(exercises: [Exercise]) {
        for exercise in exercises {
            viewContext.delete(exercise)
        }
    }
    
    func getExercisesAsync() async throws -> [Exercise]? {
        await viewContext.perform {
            let request: NSFetchRequest = NSFetchRequest<Exercise>(entityName: "Exercise")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            do {
                let fetchResult = try self.viewContext.fetch(request)
                return fetchResult
            } catch let error as NSError {
                print("Erreur pour récupérer les exercices : \(error), \(error.userInfo)")
                return nil
            }
        }
    }
    
    func saveExerciseAsync(category: String,
                           duration: Int,
                           intensity: Int,
                           startDate: Date) async throws {
        await viewContext.perform {
            let exercice = Exercise()
            exercice.category = category
            exercice.startDate = startDate
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
