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
    
    private lazy var fakePersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "dummyEntity")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    //ajouter un exercice et voir s'il y en a un
    func test_WhenNoExerciseIsInDatabase_AddAnExercise_CheckInDB() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let viewModel = AddExerciseViewModel(context: PersistenceController.shared.context)
        
        // add an exercise
        viewModel.intensity = 1
        viewModel.duration = 30
        viewModel.startTime = Date()
        viewModel.category = "Football"

        let expectation = [XCTestExpectation(description: "fetch empty list of exercise")]
        
        let _ = await viewModel.addExercise()
        
        // get the exercise from db
        let viewModelExerciseList = ExerciseListViewModel(context: PersistenceController.shared.context)
        
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
        let viewModel = AddExerciseViewModel(context: fakePersistentContainer.viewContext)
        
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }

    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        for exercice in objects {
            context.delete(exercice)
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
}
