//
//  Exercise.swift
//  Arista
//
//  Created by Hugues BOUSSELET on 15/02/2025.
//

import Foundation
import CoreData

extension Exercise {
    
    static func getExercises(context: NSManagedObjectContext) throws -> [Exercise] {
        let request: NSFetchRequest = NSFetchRequest<Exercise>(entityName: "Exercise")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return try context.fetch(request)
    }
    
    static func saveExercise(context: NSManagedObjectContext, exerciceToSave: Exercise) throws {
        let exercice = Exercise(context: context)
        exercice.category = exerciceToSave.category
        exercice.startDate = exerciceToSave.startDate
        exercice.user = exerciceToSave.user
        exercice.duration = exerciceToSave.duration
        try context.save() 
    }
}
