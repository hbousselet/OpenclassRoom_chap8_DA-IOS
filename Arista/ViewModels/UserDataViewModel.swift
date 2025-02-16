//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class UserDataViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    var showAlert: Bool = false
    var alertReason: ErrorHandler = .none

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUserData()
    }

    private func fetchUserData() {
        do {
            guard let user = try User.getUser(context: viewContext) else { return }
            firstName = user.firstName ?? ""
            lastName = user.lastName ?? ""
        } catch {
            showAlert = true
            alertReason = .fetchCoreDataFailed(" Not able to fetch users data: \(error.localizedDescription)")
            print("Not able to fetch users data: \(error.localizedDescription)")
        }
    }
}
