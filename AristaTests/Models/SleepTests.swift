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
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = Sleep.fetchRequest()
        
        let objects = try! context.fetch(fetchRequest)
        
        for sleep in objects {
            context.delete(sleep)
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
    
    func test_WhenNoSleepIsInDatabase_GetSleep_ReturnEmptyList() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let data = SleepRepository(viewContext: PersistenceController.shared.context)
                
        let sleeps = try! await data.getSleepsAsync()
        
        guard let sleepsFetched = sleeps else {
            XCTFail("Should return a list of Sleep")
            return
        }
        XCTAssert(sleepsFetched.isEmpty == true)
    }
    
    func test_WhenAddingMultipleSleepsInDatabase_GetSleeps_ReturnAListContainingTheSleepsInTheRightOrder() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60*60*24))
        let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
        
        
        
        addSleep(context: PersistenceController.shared.context,
                    duration: 10,
                    quality: 5,
                    startDate: date1,
                    userFirstName: "Erica",
                    userLastName: "Marcusi")
        
        addSleep(context: PersistenceController.shared.context,
                    duration: 120,
                    quality: 1,
                    startDate: date3,
                    userFirstName: "Erice",
                    userLastName: "Marceau")
        
        addSleep(context: PersistenceController.shared.context,
                    duration: 30,
                    quality: 5,
                    startDate: date2,
                    userFirstName: "Frédericd",
                    userLastName: "Marcus")
        
        let data = SleepRepository(viewContext: PersistenceController.shared.context)
                
        let sleeps = try! await data.getSleepsAsync()
        
        guard let sleepsFetched = sleeps else {
            XCTFail("Should return a list of Sleep")
            return
        }
                        
        XCTAssert(sleepsFetched.count == 3)
        XCTAssert(sleepsFetched[0].duration == 120)
        XCTAssert(sleepsFetched[1].duration == 30)
        XCTAssert(sleepsFetched[2].duration == 10)
    }
}
