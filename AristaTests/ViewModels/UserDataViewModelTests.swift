////
////  UserDataViewModelTests.swift
////  AristaTests
////
////  Created by Hugues BOUSSELET on 16/02/2025.
//

import XCTest
import CoreData
import Combine

@testable import Arista

@MainActor
final class UserDataViewModelTests: XCTestCase {
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
    
    func test_WhenNoUserIsInDatabase_FetchUser_ReturnNil() async {
        let userRepoMock = UserRepository(viewContext: mockPersistentContainer.viewContext)
        
        let viewModel = UserDataViewModel(userRepository: userRepoMock)
        await viewModel.fetchUserData()
        
        XCTAssert(viewModel.firstName == "")
        XCTAssert(viewModel.lastName == "")
    }
    
    
    
    func test_WhenAUserInDatabase_FetchUser_ReturnAUser() async {
        // Clean manually all data
        let userRepoMock = UserRepository(viewContext: mockPersistentContainer.viewContext)
        
        let viewModel = UserDataViewModel(userRepository: userRepoMock)
                
        addUser(context: mockPersistentContainer.viewContext,
                userFirstName: "Ericw",
                userLastName: "Marcus")
        
        await viewModel.fetchUserData()
        
        XCTAssert(viewModel.firstName == "Ericw")
        XCTAssert(viewModel.lastName == "Marcus")
    }
    
    func test_ToTriggerAlert() async {
        // Clean manually all data
        emptyEntities(context: mockPersistentContainer.viewContext)
                
        let viewModel = UserDataViewModel(userRepository: nil)
                
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
}
