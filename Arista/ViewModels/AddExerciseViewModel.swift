//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class AddExerciseViewModel: ObservableObject {
    @Published var category: String = ""
    @Published var startTime: Date = Date()
    @Published var duration: Int = 0
    @Published var intensity: Int = 0
    
    @Published var showAlert: Bool = false
    @Published var alertReason: ErrorHandler = .none

    let exerciseRepository: ExerciseRepository


    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.exerciseRepository = .init(viewContext: context)
    }

    func addExercise() async -> Bool {
        do {
            try await exerciseRepository.saveExerciseAsync(category: category, duration: duration, intensity: intensity, startDate: startTime)
            return true
        } catch {
            showAlert = true
            alertReason = .writeInCoreDataFailed("Not able to write your exercise in DB: \(error.localizedDescription)")
            return false
        }
    }
    
    func checkDurationValidity() {
        
    }
}
