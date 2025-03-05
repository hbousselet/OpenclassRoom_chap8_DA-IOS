//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

import CoreData

@MainActor
class ExerciseListViewModel: ObservableObject {
    @Published var exercises = [Exercise]()
    
    var showAlert: Bool = false
    var alertReason: ErrorHandler = .none

    let exerciseRepository: ExerciseRepository?
    
    init(exerciseRepository: ExerciseRepository? = ExerciseRepository(viewContext: PersistenceController.shared.context)) {
        self.exerciseRepository = exerciseRepository
        if self.exerciseRepository == nil {
            self.showAlert = true
            self.alertReason = .cantLoadRepository("Not able to load CoreData")
        }
    }
    
    func deleteExercise(at offset: IndexSet) async {
        let selectedExercises = offset.map { exercises[$0] }
        await exerciseRepository?.delete(exercises: selectedExercises)
    }
    
    func fetchExercises() async {
        do {
            let exercices = try await exerciseRepository?.get()
            exercises = exercices ?? []
        } catch {
            showAlert = true
            alertReason = .fetchCoreDataFailed(" Not able to fetch your exercises datas: \(error.localizedDescription)")
        }
    }
}
