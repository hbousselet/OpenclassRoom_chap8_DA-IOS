//
//  UserDataViewModelTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
import Combine

@testable import Arista

final class UserDataViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
//    var persistenceForTest = PersistenceController(inMemory: true)
    
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
    
    func test_WhenNoUserIsInDatabase_FetchUser_ReturnNil() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let viewModel = UserDataViewModel(context: persistenceController.container.viewContext)
        
        XCTAssert(viewModel.firstName == "")
        XCTAssert(viewModel.lastName == "")
    }
    
    
    
    func test_WhenAUserInDatabase_FetchUser_ReturnAUser() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
                
        addUser(context: persistenceController.container.viewContext,
                userFirstName: "Pierre",
                userLastName: "Jean")
        
        let viewModel = UserDataViewModel(context: persistenceController.container.viewContext)
        
        XCTAssert(viewModel.firstName == "Pierre")
        XCTAssert(viewModel.lastName == "Jean")
        XCTAssert(viewModel.showAlert == false)
    }
    
    func test_ToTriggerAlert() {
        let viewModel = UserDataViewModel(context: fakePersistentContainer.viewContext)
        
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
    
    
    
    
    
//    func test_WhenAddingMultipleExerciseInDatabase_FetchExercise_ReturnAListContainingTheExerciseInTheRightOrder() {
//        // Clean manually all data
//        let persistenceController = PersistenceController(inMemory: true)
//        emptyEntities(context: persistenceController.container.viewContext)
//        
//        let date1 = Date()
//        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
//        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
//        
//        addExercice(context: persistenceController.container.viewContext,
//                    category: "Football",
//                    duration: 10,
//                    intensity: 5,
//                    startDate: date1,
//                    userFirstName: "Ericn",
//                    userLastName: "Marcusi")
//        
//        addExercice(context: persistenceController.container.viewContext,
//                    category: "Running",
//                    duration: 120,
//                    intensity: 1,
//                    startDate: date3,
//                    userFirstName: "Ericb",
//                    userLastName: "Marceau")
//        
//        addExercice(context: persistenceController.container.viewContext,
//                    category: "Fitness",
//                    duration: 30,
//                    intensity: 5,
//                    startDate: date2,
//                    userFirstName: "Frédericp",
//                    userLastName: "Marcus")
//        
//        let viewModel = ExerciseListViewModel(context: persistenceController.container.viewContext)
//        let expectation = XCTestExpectation(description: "fetch exercises")
//        
//        viewModel.$exercises
//            .sink { exercises in
//                XCTAssert(exercises.count == 3)
//                XCTAssert(exercises[0].category == "Running")
//                XCTAssert(exercises[1].category == "Fitness")
//                XCTAssert(exercises[2].category == "Football")
//                expectation.fulfill()
//            }
//            .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 10)
//        
//    }

    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Exercise.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        for exercice in objects {
            context.delete(exercice)
        }
        try! context.save()
    }
    
    private func addUser(context: NSManagedObjectContext,
                         userFirstName: String,
                         userLastName: String) {
        
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = "\(userFirstName).\(userLastName)@example.com"
        newUser.password = "password"
        
        try! context.save()
    }
}
