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
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let userRepoMock = UserRepository(viewContext: PersistenceController.shared.context)
        
        let viewModel = UserDataViewModel(userRepository: userRepoMock)
        await viewModel.fetchUserData()
        
        XCTAssert(viewModel.firstName == "")
        XCTAssert(viewModel.lastName == "")
    }
    
    
    
    func test_WhenAUserInDatabase_FetchUser_ReturnAUser() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
        
        let userRepoMock = UserRepository(viewContext: PersistenceController.shared.context)
        
        let viewModel = UserDataViewModel(userRepository: userRepoMock)
                
        addUser(context: PersistenceController.shared.context,
                userFirstName: "Ericw",
                userLastName: "Marcus")
        
        await viewModel.fetchUserData()
        
        XCTAssert(viewModel.firstName == "Ericw")
        XCTAssert(viewModel.lastName == "Marcus")
    }
    
    func test_ToTriggerAlert() async {
        // Clean manually all data
        emptyEntities(context: PersistenceController.shared.context)
                
        let viewModel = UserDataViewModel(userRepository: nil)
                
        XCTAssert(viewModel.showAlert == true)
        XCTAssertNotNil(viewModel.alertReason)
    }
}
