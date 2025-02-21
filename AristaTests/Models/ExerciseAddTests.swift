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
    func test_WhenNoExerciseIsInDatabase_AddAnExercise_ReturnAnExerciese() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let date = Date()
        
        let data = ExerciseRepository(viewContext: PersistenceController.shared.context)
                    
        do {
            try await data.saveExerciseAsync(category: "Football",
                                      duration: 60,
                                      intensity: 8,
                                      startDate: date)
        } catch {
            XCTAssertNil(error)
        }
        
        let exercise = try! await data.getExercisesAsync()
        
        guard let exerciseFetched = exercise else {
            XCTFail("Should return a list of Exercises")
            return
        }
        
        XCTAssert((exerciseFetched.count == 1))
        XCTAssert(exerciseFetched.first?.category == "Football")
        XCTAssert(exerciseFetched.first?.duration == 60)
        XCTAssert(exerciseFetched.first?.intensity == 8)
        XCTAssert(exerciseFetched.first?.startDate == date)
    }
    
    //ajouter plusieurs exercices => fetch et verifier qu'il y en ait plusieurs
    func test_WhenNoExerciseIsInDatabase_AddSeveralExercises_ReturnExercises() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let date = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        let data = ExerciseRepository(viewContext: PersistenceController.shared.context)
        
        do {
            try await data.saveExerciseAsync(category: "Football",
                                             duration: 60,
                                             intensity: 8,
                                             startDate: date)
            
            try await data.saveExerciseAsync(category: "Baseball",
                                             duration: 70,
                                             intensity: 9,
                                             startDate: date2)
            
            try await data.saveExerciseAsync(category: "Rugby",
                                             duration: 80,
                                             intensity: 1,
                                             startDate: date3)
            
        } catch {
            XCTAssertNil(error)
        }
        
        let exercises = try! await data.getExercisesAsync()
        
        guard let exerciseFetched = exercises else {
            XCTFail("Should return a list of Exercises")
            return
        }
        
        XCTAssert((exerciseFetched.count == 3))
        XCTAssert(exerciseFetched[0].category == "Rugby")
        XCTAssert(exerciseFetched[1].category == "Baseball")
        XCTAssert(exerciseFetched[2].category == "Football")
    }
}
