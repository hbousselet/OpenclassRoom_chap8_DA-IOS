//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class UserDataViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    var showAlert: Bool = false
    var alertReason: ErrorHandler = .none
    
    var userRepository: UserRepository
    
    @Published var bedTimeImagePosition: Position = .zero
    @Published var wakeUpTimeImagePosition: Position = .zero
    
    @Published var radius: CGFloat = 100
    var wakeUpIconAngle: Double = 0
    
    let sleepDurationMinutes: Double = 8 * 60
    let maxSleepDurationMinutes: Double = 12 * 60
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.userRepository = UserRepository(viewContext: context)
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
    
    func reComputePosition() {
        let angle = 32.4
        wakeUpTimeImagePosition = Position(x: -1 * Int(radius * cos(angle)),
                                                  y: -1 * Int(radius * sin(-angle)))
    }
    
    func computePosition(of sleep: Double, for radius: Double) -> Position {
        let angle = (sleep / maxSleepDurationMinutes) * 60
        return Position(x: Int(radius * cos(.pi * angle)),
                 y: Int(radius * sin(.pi * angle)))
    }
    
    struct Position: Codable {
        var x: Int
        var y: Int
        
        static let zero = Self(x: 0, y: 0)
    }
}

extension UserDataViewModel.Position {
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x-size.width/2, y: center.y-size.height/2), size: size)
    }
}
