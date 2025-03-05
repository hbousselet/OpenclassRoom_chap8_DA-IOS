//
//  SleepTests.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
@testable import Arista

final class SleepTests: XCTestCase {
    
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
    
    func test_WhenNoSleepIsInDatabase_GetSleep_ReturnEmptyList() async {
        let sleepRepoMock = SleepRepository(viewContext: mockPersistentContainer.viewContext)
        
        guard let sleepsFetched: [Sleep] = try! await sleepRepoMock?.get() else {
            XCTFail("Should return a list of Exercises")
            return
        }
        
        XCTAssert(sleepsFetched.isEmpty)
    }
    
    func test_WhenAddingMultipleSleepsInDatabase_GetSleeps_ReturnAListContainingTheSleepsInTheRightOrder() async {
        let sleepRepoMock = SleepRepository(viewContext: mockPersistentContainer.viewContext)
        
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
        
                
        guard let sleepsFetched: [Sleep] = try! await sleepRepoMock?.get() else {
            XCTFail("Should return a list of Exercises")
            return
        }
                        
        XCTAssert(sleepsFetched.count == 3)
        XCTAssert(sleepsFetched[0].duration == 120)
        XCTAssert(sleepsFetched[1].duration == 30)
        XCTAssert(sleepsFetched[2].duration == 10)
    }
}
