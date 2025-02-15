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
    
    static func saveExercise(context: NSManagedObjectContext,
                             category: String,
                             duration: Int,
                             intensity: Int,
                             startDate: Date) throws {
        let exercice = Exercise(context: context)
        exercice.category = category
        exercice.startDate = startDate
        exercice.intensity = Int64(intensity)
        exercice.duration = Int64(duration)
        try context.save()
    }
}
