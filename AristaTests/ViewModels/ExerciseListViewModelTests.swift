//
//  ExerciseListViewModelTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
import Combine

@testable import Arista

@MainActor
final class ExerciseListViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
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
    
    
    func test_WhenNoExerciseIsInDatabase_FetchExercise_ReturnEmptyList() async {
        // Clean manually all data
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        
        
        let viewModel = ExerciseListViewModel(exerciseRepository: exerciseRepoMock)
        let expectation = [XCTestExpectation(description: "fetch empty list of exercise")]
        
        await viewModel.fetchExercises()
        
        viewModel.$exercises
            .sink { exercises in
                XCTAssert(exercises.isEmpty)
                expectation.first?.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: expectation)
        
    }
    
    func test_WhenAddingOneExerciseInDatabase_FetchExercise_ReturnAListContainingTheExercise() async {
        // Clean manually all data
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        let viewModel = ExerciseListViewModel(exerciseRepository: exerciseRepoMock)
        
        let date = Date()
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date,
                    userFirstName: "Ericw", userLastName: "Marcus")
        
        await viewModel.fetchExercises()
        
        XCTAssert(viewModel.exercises.first?.category == "Football")
    }
    
    
    func test_WhenAddingMultipleExerciseInDatabase_FetchExercise_ReturnAListContainingTheExerciseInTheRightOrder() async {
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        let viewModel = ExerciseListViewModel(exerciseRepository: exerciseRepoMock)
        
        let expectation = [XCTestExpectation(description: "fetch one exercise")]
        
        let date = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Football",
                    duration: 10,
                    intensity: 5,
                    startDate: date,
                    userFirstName: "Ericn",
                    userLastName: "Marcusi")
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Running",
                    duration: 120,
                    intensity: 1,
                    startDate: date3,
                    userFirstName: "Ericb",
                    userLastName: "Marceau")
        
        addExercice(context: mockPersistentContainer.viewContext,
                    category: "Fitness",
                    duration: 30,
                    intensity: 5,
                    startDate: date2,
                    userFirstName: "Frédericp",
                    userLastName: "Marcus")
        
        await viewModel.fetchExercises()
        
        
        viewModel.$exercises
            .sink { exercises in
                XCTAssert(exercises.count == 3)
                XCTAssert(exercises[0].category == "Running")
                XCTAssert(exercises[1].category == "Fitness")
                XCTAssert(exercises[2].category == "Football")
                expectation.first?.fulfill()
            }
            .store(in: &cancellables)
        await fulfillment(of: expectation)
    }
    
    func test_ToTriggerAlert() async {        
        let viewModel = ExerciseListViewModel(exerciseRepository: nil)
                
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
}
