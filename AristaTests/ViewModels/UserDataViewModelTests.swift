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
    
    private lazy var fakePersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "arista")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "Arista")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func test_WhenNoUserIsInDatabase_FetchUser_ReturnNil() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let viewModel = UserDataViewModel(context: PersistenceController.shared.context)
        await viewModel.fetchUserData()
        
        XCTAssert(viewModel.firstName == "")
        XCTAssert(viewModel.lastName == "")
    }
    
    
    
    func test_WhenAUserInDatabase_FetchUser_ReturnAUser() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let viewModel = UserDataViewModel(context: PersistenceController.shared.context)
                
        addUser(context: PersistenceController.shared.context,
                userFirstName: "Ericw",
                userLastName: "Marcus")
        
        await viewModel.fetchUserData()
        
        XCTAssert(viewModel.firstName == "Ericw")
        XCTAssert(viewModel.lastName == "Marcus")
        
        //OK TOO +>
//        // Clean manually all data
//        emptyEntities(context: persistentContainer.viewContext)
//        
//        let viewModel = UserDataViewModel(context: persistentContainer.viewContext)
//                
//        addUser(context: persistentContainer.viewContext,
//                userFirstName: "Ericw",
//                userLastName: "Marcus")
//        
//        await viewModel.fetchUserData()
//        
//        XCTAssert(viewModel.firstName == "Ericw")
//        XCTAssert(viewModel.lastName == "Marcus")
    }
    
    func test_ToTriggerAlert() async {
        let viewModel = UserDataViewModel(context: fakePersistentContainer.viewContext)
        
        await viewModel.fetchUserData()
        
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }

    
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
}
