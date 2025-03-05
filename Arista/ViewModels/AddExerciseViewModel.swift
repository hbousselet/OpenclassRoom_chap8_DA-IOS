//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

class AddExerciseViewModel: ObservableObject {
    @Published var category: String = ""
    @Published var startTime: Date = Date()
    @Published var duration: Int = 0
    @Published var intensity: Int = 0
    
    @Published var showAlert: Bool = false
    @Published var alertReason: ErrorHandler = .none

    let exerciseRepository: ExerciseRepository?
    
    init(exerciseRepository: ExerciseRepository? = ExerciseRepository(viewContext: PersistenceController.shared.context)) {
        self.exerciseRepository = exerciseRepository
        if self.exerciseRepository == nil {
            self.showAlert = true
            self.alertReason = .cantLoadRepository("Not able to load CoreData")
        }
    }

    func addExercise() async -> Bool {
        do {
            try await exerciseRepository?.save(category: category, duration: duration, intensity: intensity, startDate: startTime)
            return true
        } catch {
            showAlert = true
            alertReason = .writeInCoreDataFailed("Not able to write your exercise in DB: \(error.localizedDescription)")
            return false
        }
    }
}
