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
        let userRepoMock = UserRepository(viewContext: mockPersistentContainer.viewContext)
                
        guard let usersFetched: [User] = try! await userRepoMock?.get() else {
            XCTFail("Should return a list of Users")
            return
        }
        
        XCTAssert(usersFetched.isEmpty)
    }
    
    func test_WhenHavingOneUserInDatabase_GetUser_ReturnAUser() async {
        let userRepoMock = UserRepository(viewContext: mockPersistentContainer.viewContext)
        
        addUser(context: mockPersistentContainer.viewContext,
                userFirstName: "Pierrot",
                userLastName: "DelaVega")
        
                
        guard let usersFetched: [User] = try! await userRepoMock?.get() else {
            XCTFail("Should return a list of Users")
            return
        }
        
        XCTAssert(usersFetched.first?.firstName == "Pierrot")
        XCTAssert(usersFetched.first?.lastName == "DelaVega")
    }
}
