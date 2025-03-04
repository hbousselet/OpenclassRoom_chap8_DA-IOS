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
    
    lazy var model: NSManagedObjectModel = {
        return PersistenceController.model(name: PersistenceController.modelName)
    }()
    
    lazy var mockPersistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "Arista", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            
            if let error = error {
                fatalError("Unable to create in memory persistent store")
            }
        }
        
        return persistentContainer
    }()
    
    //ajouter un Exercice => fetch qu'il y a que un
    func test_WhenNoExerciseIsInDatabase_AddAnExercise_ReturnAnExerciese() async {
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)

        let date = Date()
                            
        do {
            try await exerciseRepoMock?.save(category: "Football",
                                      duration: 60,
                                      intensity: 8,
                                      startDate: date)
        } catch {
            XCTAssertNil(error)
        }
        
        guard let exercisesFetched: [Exercise] = try! await exerciseRepoMock?.get() else {
            XCTFail("Should return a list of Exercises")
            return
        }
        
        XCTAssert((exercisesFetched.count == 1))
        XCTAssert(exercisesFetched.first?.category == "Football")
        XCTAssert(exercisesFetched.first?.duration == 60)
        XCTAssert(exercisesFetched.first?.intensity == 8)
        XCTAssert(exercisesFetched.first?.startDate == date)
    }
    
    func test_WhenNoExerciseIsInDatabase_AddSeveralExercises_ReturnExercises() async {
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        
        let date = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
                
        do {
            try await exerciseRepoMock?.save(category: "Football",
                                             duration: 60,
                                             intensity: 8,
                                             startDate: date)
            
            try await exerciseRepoMock?.save(category: "Baseball",
                                             duration: 70,
                                             intensity: 9,
                                             startDate: date2)
            
            try await exerciseRepoMock?.save(category: "Rugby",
                                             duration: 80,
                                             intensity: 1,
                                             startDate: date3)
            
        } catch {
            XCTAssertNil(error)
        }
        
        guard let exercisesFetched: [Exercise] = try! await exerciseRepoMock?.get() else {
            XCTFail("Should return a list of Exercises")
            return
        }
        
        XCTAssert((exercisesFetched.count == 3))
        XCTAssert(exercisesFetched[0].category == "Rugby")
        XCTAssert(exercisesFetched[1].category == "Baseball")
        XCTAssert(exercisesFetched[2].category == "Football")
    }
}
