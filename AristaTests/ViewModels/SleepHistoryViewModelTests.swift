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
    
    private func addSleep(context: NSManagedObjectContext,
                          duration: Int,
                          quality: Int,
                          startDate: Date,
                          userFirstName: String,
                          userLastName: String) {
        
        let newUser = User(entity: NSEntityDescription.entity(forEntityName: "User", in: context)!, insertInto: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = "\(userFirstName).\(userLastName)@example.com"
        newUser.password = "password"
        
        try! context.save()
        
        let newSleep = Sleep(entity: NSEntityDescription.entity(forEntityName: "Sleep", in: context)!, insertInto: context)
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
    
    func testFetchSleepDataInError() async {
        let sleepRepositoryMock = MockSleepRepository(context: mockPersistentContainer.viewContext) 
        let viewModel = SleepHistoryViewModel(sleepRepository: sleepRepositoryMock)
        
        await viewModel.fetchSleepSessions()
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
}

class MockSleepRepository: SleepRepository {
    var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init(viewContext: context)
    }
    
    override func get() async throws -> [Sleep] {
        throw ErrorHandler.fetchCoreDataFailed("unable to fetch")
    }
}
