//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

@MainActor
class UserDataViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    var showAlert: Bool = false
    var alertReason: ErrorHandler = .none
    
    var userRepository: UserRepository

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        self.userRepository = UserRepository(viewContext: viewContext)
        fetchUserData()
    }
    
    private func fetchUserData() {
        Task {
            do {
                guard let user = try await userRepository.getUserAsync() else { return }
                firstName = user.firstName ?? ""
                lastName = user.lastName ?? ""
            } catch {
                showAlert = true
                alertReason = .fetchCoreDataFailed(" Not able to fetch users data: \(error.localizedDescription)")
                print("Not able to fetch users data: \(error.localizedDescription)")
            }
        }
    }
}
