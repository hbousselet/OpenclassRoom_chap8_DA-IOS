//
//  ExerciseTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.


import XCTest
import CoreData
@testable import Arista

final class ExerciceTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for user in objects {
            context.delete(user)
        }
        try! context.save()
    }

    private func addExercice(context: NSManagedObjectContext,
                             category: String,
                             duration: Int,
                             intensity: Int,
                             startDate: Date,
                             userFirstName: String,
                             userLastName: String) {
        
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = "\(userFirstName).\(userLastName)@example.com"
        newUser.password = "password"
        
        try! context.save()
        
        let newExercise = Exercise(context: context)
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate
        newExercise.user = newUser
        try! context.save()
    }
    
    func test_WhenNoExerciseIsInDatabase_GetExercise_ReturnEmptyList() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let exerciseRepoMock = ExerciseRepository(viewContext: PersistenceController.shared.context)
        
        do {
            guard let exercices: [Exercise] = try await exerciseRepoMock?.getAsync() else {
                XCTFail("Should return a list of Exercises")
                return
            }
            XCTAssert(exercices.isEmpty == true)
        } catch {
            XCTFail("Should return a list of Exercises")
        }
    }

    func test_WhenAddingOneExerciseInDatabase_GetExercise_ReturnAListContainingTheExercise() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let exerciseRepoMock = ExerciseRepository(viewContext: PersistenceController.shared.context)
        
        let date = Date()
        
        addExercice(context: PersistenceController.shared.context,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date,
                    userFirstName: "Eric", userLastName: "Marcus")
        
                
        guard let exercisesFetched: [Exercise] = try! await exerciseRepoMock?.getAsync() else {
            XCTFail("Should return a list of Exercises")
            return
        }
        
        XCTAssert(exercisesFetched.isEmpty == false)
        XCTAssert(exercisesFetched.first?.category == "Football")
        XCTAssert(exercisesFetched.first?.duration == 10)
        XCTAssert(exercisesFetched.first?.intensity == 5)
        XCTAssert(exercisesFetched.first?.startDate == date)
    }
    
    

    func test_WhenAddingMultipleExerciseInDatabase_GetExercise_ReturnAListContainingTheExerciseInTheRightOrder() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let exerciseRepoMock = ExerciseRepository(viewContext: PersistenceController.shared.context)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        
        
        addExercice(context: PersistenceController.shared.context,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date1,
                    userFirstName: "Erica",
                    userLastName: "Marcusi")
        
        addExercice(context: PersistenceController.shared.context,
                    category: "Running",
                    duration: 120,
                    intensity: 1,
                    startDate: date3,
                    userFirstName: "Erice",
                    userLastName: "Marceau")
        
        addExercice(context: PersistenceController.shared.context,
                    category: "Fitness",
                    duration: 30,
                    intensity: 5,
                    startDate: date2,
                    userFirstName: "Frédericd",
                    userLastName: "Marcus")
                        
        guard let exercisesFetched: [Exercise] = try! await exerciseRepoMock?.getAsync() else {
            XCTFail("Should return a list of Exercises")
            return
        }
                        
        XCTAssert(exercisesFetched.count == 3)
        XCTAssert(exercisesFetched[0].category == "Running")
        XCTAssert(exercisesFetched[1].category == "Fitness")
        XCTAssert(exercisesFetched[2].category == "Football")
    }
}
