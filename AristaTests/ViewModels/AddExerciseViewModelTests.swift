//
//  AddExerciseViewModelTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
import Combine

@testable import Arista

@MainActor
final class AddExerciseViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    
    var model: NSManagedObjectModel!
    
    var mockPersistentContainer: NSPersistentContainer!
    
    override func setUp() {
        model = PersistenceController.model(name: PersistenceController.modelName)
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
    
    //ajouter un exercice et voir s'il y en a un
    func test_WhenNoExerciseIsInDatabase_AddAnExercise_CheckInDB() async {        
        let exerciseRepoMock = ExerciseRepository(viewContext: mockPersistentContainer.viewContext)
        
        let viewModel = AddExerciseViewModel(exerciseRepository: exerciseRepoMock)
        
        // add an exercise
        viewModel.intensity = 1
        viewModel.duration = 30
        viewModel.startTime = Date()
        viewModel.category = "Football"

        let expectation = [XCTestExpectation(description: "fetch empty list of exercise")]
        
        let _ = await viewModel.addExercise()
        
        // get the exercise from db
        let viewModelExerciseList = ExerciseListViewModel(exerciseRepository: exerciseRepoMock)
        
        await viewModelExerciseList.fetchExercises()
                
        
        viewModelExerciseList.$exercises
            .sink { exercises in
                XCTAssert(exercises.count == 1)
                XCTAssert(exercises.first?.category == "Football")
                XCTAssert(exercises.first?.duration == 30)
                XCTAssert(exercises.first?.intensity == 1)
                expectation.first?.fulfill()
            }
            .store(in: &cancellables)
    
        await fulfillment(of: expectation)
    }
    
    // tester l'alerte
    func test_ToTriggerAlert() {
        let viewModel = AddExerciseViewModel(exerciseRepository: nil)
        
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
    
    func test_RiseAlertWhenCantSaveExercise() async {
        let exerciseRepoMock = MockExerciseRepository(context: mockPersistentContainer.viewContext)
        let viewModel = AddExerciseViewModel(exerciseRepository: exerciseRepoMock)
        
        let _ = await viewModel.addExercise()
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
}

class MockExerciseRepository: ExerciseRepository {
    typealias T = Exercise
    
    var context: NSManagedObjectContext
    
    init?(context: NSManagedObjectContext) {
        self.context = context
        super.init(viewContext: context)
    }
    
    override func get() async throws -> [Exercise] {
        throw ErrorHandler.fetchCoreDataFailed("unable to fetch")
    }
    
    override func save(category: String, duration: Int, intensity: Int, startDate: Date) async throws {
        throw ErrorHandler.writeInCoreDataFailed("Not able to write your exercise in DB")
    }
}
