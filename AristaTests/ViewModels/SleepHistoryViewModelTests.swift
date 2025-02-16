//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
import Combine

@testable import Arista

final class SleepHistoryViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()
    var persistenceForTest = PersistenceController(inMemory: true)
    
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
    
    func test_WhenNoSleepIsInDatabase_FetchSleep_ReturnEmptyList() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
        
        let viewModel = SleepHistoryViewModel(context: persistenceController.container.viewContext)
        
        XCTAssert(viewModel.sleepSessions.isEmpty)
    }
    
    
    
    func test_WhenAddingSeveralSleepsInDatabase_FetchSleeos_ReturnAListContainingTheSleeps() {
        // Clean manually all data
        let persistenceController = PersistenceController(inMemory: true)
        emptyEntities(context: persistenceController.container.viewContext)
                
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        
        
        addSleep(context: persistenceController.container.viewContext,
                    duration: 10,
                    quality: 5,
                    startDate: date1,
                    userFirstName: "Erica",
                    userLastName: "Marcusi")
        
        addSleep(context: persistenceController.container.viewContext,
                    duration: 120,
                    quality: 1,
                    startDate: date3,
                    userFirstName: "Erice",
                    userLastName: "Marceau")
        
        addSleep(context: persistenceController.container.viewContext,
                    duration: 30,
                    quality: 5,
                    startDate: date2,
                    userFirstName: "Frédericd",
                    userLastName: "Marcus")
                
        let viewModel = SleepHistoryViewModel(context: persistenceController.container.viewContext)
        let expectation = XCTestExpectation(description: "fetch a list of sleeps")
        
        viewModel.$sleepSessions
            .sink { sleeps in
                XCTAssert(sleeps.count == 3)
                XCTAssert(sleeps[0].duration == 120)
                XCTAssert(sleeps[1].duration == 30)
                XCTAssert(sleeps[2].duration == 10)
                XCTAssert(viewModel.showAlert == false)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
    
    func test_ToTriggerAlert() {
        let viewModel = SleepHistoryViewModel(context: fakePersistentContainer.viewContext)
        
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
    
    private func addSleep(context: NSManagedObjectContext,
                          duration: Int,
                          quality: Int,
                          startDate: Date,
                          userFirstName: String,
                          userLastName: String) {
        
        let newUser = User(context: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = "\(userFirstName).\(userLastName)@example.com"
        newUser.password = "password"
        
        try! context.save()
        
        let newSleep = Sleep(context: context)
        newSleep.duration = Int64(duration)
        newSleep.quality = Int64(quality)
        newSleep.startDate = startDate
        newSleep.user = newUser
        try! context.save()
    }
}
