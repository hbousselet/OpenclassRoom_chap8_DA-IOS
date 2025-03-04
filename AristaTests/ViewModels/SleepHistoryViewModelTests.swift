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

@MainActor
final class SleepHistoryViewModelTests: XCTestCase {
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
    
    func test_WhenNoSleepIsInDatabase_FetchSleep_ReturnEmptyList() {
        let sleepRepoMock = SleepRepository(viewContext: mockPersistentContainer.viewContext)
        
        let viewModel = SleepHistoryViewModel(sleepRepository: sleepRepoMock)
                        
        XCTAssert(viewModel.sleepSessions.isEmpty)
    }
    
    
    
    func test_WhenAddingSeveralSleepsInDatabase_FetchSleeos_ReturnAListContainingTheSleeps() async {
        let sleepRepoMock = SleepRepository(viewContext: mockPersistentContainer.viewContext)
        
        let viewModel = SleepHistoryViewModel(sleepRepository: sleepRepoMock)
                
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        
        
        addSleep(context: mockPersistentContainer.viewContext,
                    duration: 10,
                    quality: 5,
                    startDate: date1,
                    userFirstName: "Erica",
                    userLastName: "Marcusi")
        
        addSleep(context: mockPersistentContainer.viewContext,
                    duration: 120,
                    quality: 1,
                    startDate: date3,
                    userFirstName: "Erice",
                    userLastName: "Marceau")
        
        addSleep(context: mockPersistentContainer.viewContext,
                    duration: 30,
                    quality: 5,
                    startDate: date2,
                    userFirstName: "Frédericd",
                    userLastName: "Marcus")
                
        let expectation = [XCTestExpectation(description: "fetch a list of sleeps")]
        
        await viewModel.fetchSleepSessions()
        
        viewModel.$sleepSessions
            .sink { sleeps in
                XCTAssert(sleeps.count == 3)
                XCTAssert(sleeps[0].duration == 120)
                XCTAssert(sleeps[1].duration == 30)
                XCTAssert(sleeps[2].duration == 10)
                XCTAssert(viewModel.showAlert == false)
                expectation.first?.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: expectation)
    }
    
    func test_ToTriggerAlert() {
        let viewModel = SleepHistoryViewModel(sleepRepository: nil)
        
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
}
