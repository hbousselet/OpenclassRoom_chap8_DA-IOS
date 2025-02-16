//
//  ExerciseAddTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
@testable import Arista

final class ExerciseAddTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        
        let objects = try! context.fetch(fetchRequest)
        
        for exercice in objects {
            context.delete(exercice)
        }
        try! context.save()
    }
    
    //ajouter un Exercice => fetch qu'il y a que un
    func test_WhenNoExerciseIsInDatabase_AddAnExercise_ReturnAnExerciese() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date = Date()
        
        do {
            try Exercise.saveExercise(context: persistenceController.container.viewContext,
                                      category: "Football",
                                      duration: 60,
                                      intensity: 8,
                                      startDate: date)
        } catch {
            XCTAssertNil(error)
        }
        
        let exercise = try! Exercise.getExercises(context: persistenceController.container.viewContext)
        
        XCTAssert((exercise.count == 1))
        XCTAssert(exercise.first?.category == "Football")
        XCTAssert(exercise.first?.duration == 60)
        XCTAssert(exercise.first?.intensity == 8)
        XCTAssert(exercise.first?.startDate == date)
    }
    
    //ajouter plusieurs exercices => fetch et verifier qu'il y en ait plusieurs
    func test_WhenNoExerciseIsInDatabase_AddSeveralExercises_ReturnExercises() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let date = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        do {
            try Exercise.saveExercise(context: persistenceController.container.viewContext,
                                      category: "Football",
                                      duration: 60,
                                      intensity: 8,
                                      startDate: date)
            
            try Exercise.saveExercise(context: persistenceController.container.viewContext,
                                      category: "Baseball",
                                      duration: 70,
                                      intensity: 9,
                                      startDate: date2)
            
            try Exercise.saveExercise(context: persistenceController.container.viewContext,
                                      category: "Rugby",
                                      duration: 80,
                                      intensity: 1,
                                      startDate: date3)
            
        } catch {
            XCTAssertNil(error)
        }
        
        let exercises = try! Exercise.getExercises(context: persistenceController.container.viewContext)
        
        XCTAssert((exercises.count == 3))
        XCTAssert(exercises[0].category == "Rugby")
        XCTAssert(exercises[1].category == "Baseball")
        XCTAssert(exercises[2].category == "Football")
    }
}
