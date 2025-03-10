//
//  ExerciseTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.


import XCTest
import CoreData
@testable import Arista

final class ExerciceTests: XCTestCase {
    
    var model: NSManagedObjectModel!
    
    var mockPersistentContainer: NSPersistentContainer!
    
    override func setUp() {
        model = PersistenceController.model(name: PersistenceController.modelName)
        let persistentContainer = NSPersistentContainer(name: "Arista", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            
            if let error = error {
                fatalError("Unable to create in memory persistent store")
            }
        }
        
        mockPersistentContainer = persistentContainer
    }
    
    override func tearDown() {
        model = nil
        mockPersistentContainer = nil
    }

    private func addExercice(context: NSManagedObjectContext,
                             category: String,
                             duration: Int,
                             intensity: Int,
                             startDate: Date,
                             userFirstName: String,
                             userLastName: String) {
        
        let newUser = User(entity: NSEntityDescription.entity(forEntityName: "User", in: context)!, insertInto: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = "\(userFirstName).\(userLastName)@example.com"
        newUser.password = "password"
        
        try! context.save()
        
        let newExercise = Exercise(entity: NSEntityDescription.entity(forEntityName: "Exercise", in: context)!, insertInto: context)
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate
        newExercise.user = newUser
        try! context.save()
    }
    
    func test_WhenNoExerciseIsInDatabase_GetExercise_ReturnEmptyList() async {
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        
        do {
            let exercices: [Exercise] = try await exerciseRepoMock.get()
            XCTAssert(exercices.isEmpty == true)
        } catch {
            XCTFail("Should return a list of Exercises")
        }
    }

    func test_WhenAddingOneExerciseInDatabase_GetExercise_ReturnAListContainingTheExercise() async {
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        
        let date = Date()
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date,
                    userFirstName: "Eric", userLastName: "Marcus")
        
                
        let exercisesFetched: [Exercise] = try! await exerciseRepoMock.get()
        
        XCTAssert(exercisesFetched.isEmpty == false)
        XCTAssert(exercisesFetched.first?.category == "Football")
        XCTAssert(exercisesFetched.first?.duration == 10)
        XCTAssert(exercisesFetched.first?.intensity == 5)
        XCTAssert(exercisesFetched.first?.startDate == date)
    }
    
    

    func test_WhenAddingMultipleExerciseInDatabase_GetExercise_ReturnAListContainingTheExerciseInTheRightOrder() async {
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date1,
                    userFirstName: "Erica",
                    userLastName: "Marcusi")
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Running",
                    duration: 120,
                    intensity: 1,
                    startDate: date3,
                    userFirstName: "Erice",
                    userLastName: "Marceau")
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Fitness",
                    duration: 30,
                    intensity: 5,
                    startDate: date2,
                    userFirstName: "Frédericd",
                    userLastName: "Marcus")
                        
        let exercisesFetched: [Exercise] = try! await exerciseRepoMock.get()
        XCTAssert(exercisesFetched.count == 3)
        XCTAssert(exercisesFetched[0].category == "Running")
        XCTAssert(exercisesFetched[1].category == "Fitness")
        XCTAssert(exercisesFetched[2].category == "Football")
    }
}
