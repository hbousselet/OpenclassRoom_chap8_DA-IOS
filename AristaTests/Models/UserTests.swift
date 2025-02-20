////
////  UserTests.swift
////  AristaTests
////
////  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
@testable import Arista

final class UserTests: XCTestCase {
    
    private func emptyEntities(context: NSManagedObjectContext) {
        let fetchRequest = User.fetchRequest()
        let objects = try! context.fetch(fetchRequest)
        
        for user in objects {
            context.delete(user)
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
    
    func test_WhenNoUserIsInDatabase_GetUser_ReturnEmptyList() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let data = UserRepository(viewContext: PersistenceController.shared.context)
                
        let user = try! await data.getUserAsync()
        
        XCTAssertNil(user)
    }
    
    func test_WhenHavingOneUserInDatabase_GetUser_ReturnAUser() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        addUser(context: PersistenceController.shared.context,
                userFirstName: "Pierrot",
                userLastName: "DelaVega")
        
        let data = UserRepository(viewContext: PersistenceController.shared.context)

                
        let user = try! await data.getUserAsync()
        
        XCTAssert(user?.firstName == "Pierrot")
        XCTAssert(user?.lastName == "DelaVega")
    }
}
