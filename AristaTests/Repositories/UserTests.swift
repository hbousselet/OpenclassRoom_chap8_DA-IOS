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
    
    private func addUser(context: NSManagedObjectContext,
                         userFirstName: String,
                         userLastName: String) {
        
        let newUser = User(entity: NSEntityDescription.entity(forEntityName: "User", in: context)!, insertInto: context)
        newUser.firstName = userFirstName
        newUser.lastName = userLastName
        newUser.email = "\(userFirstName).\(userLastName)@example.com"
        newUser.password = "password"
        
        try! context.save()
    }
    
    func test_WhenNoUserIsInDatabase_GetUser_ReturnEmptyList() async {
        let userRepoMock = UserRepository(viewContext: mockPersistentContainer.viewContext)
                
        let usersFetched: [User] = try! await userRepoMock.get()
        
        XCTAssert(usersFetched.isEmpty)
    }
    
    func test_WhenHavingOneUserInDatabase_GetUser_ReturnAUser() async {
        let userRepoMock = UserRepository(viewContext: mockPersistentContainer.viewContext)
        
        addUser(context: mockPersistentContainer.viewContext,
                userFirstName: "Pierrot",
                userLastName: "DelaVega")
        
                
        let usersFetched: [User] = try! await userRepoMock.get()
        
        XCTAssert(usersFetched.first?.firstName == "Pierrot")
        XCTAssert(usersFetched.first?.lastName == "DelaVega")
    }
}
