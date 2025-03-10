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
    
    let sleepDurationMinutes: Double = 8
    let maxSleepDurationMinutes: Double = 12
    
    init(userRepository: UserRepository = UserRepository(viewContext: PersistenceController.shared.context)) {
        self.userRepository = userRepository
    }
    
    func fetchUserData() async {
        do {
            let user: [User] = try await userRepository.get()
            firstName = user.first?.firstName ?? ""
            lastName = user.first?.lastName ?? ""
        } catch {
            showAlert = true
            alertReason = .fetchCoreDataFailed(" Not able to fetch users data: \(error.localizedDescription)")
            print("Not able to fetch users data: \(error.localizedDescription)")
        }
    }
    
    func computePosition() {
        //need to update position of bedTimeImagePosition and wakeUpTimeImagePosition based on the angle
        let angleInDegrees = 90.0
        var angleInRadians = angleInDegrees * .pi / 180.0
        bedTimeImagePosition = Position(x: Int(self.radius * cos(angleInRadians)),
                                   y: Int(self.radius * sin(angleInRadians)))
        let ratioOfSleepInDegrees = 450 - ((sleepDurationMinutes / maxSleepDurationMinutes) * 360) + 1
        angleInRadians = ratioOfSleepInDegrees * .pi / 180.0
        wakeUpTimeImagePosition = Position(x: Int(self.radius * cos(angleInRadians)),
                                             y: Int(self.radius * sin(angleInRadians)))
    }
    
    struct Position: Codable, Equatable {
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
