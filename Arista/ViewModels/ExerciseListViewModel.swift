//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

import CoreData

class ExerciseListViewModel: ObservableObject {
    @Published var exercises = [Exercise]()
    
    var showAlert: Bool = false
    var alertReason: ErrorHandler = .none

    var viewContext: NSManagedObjectContext
    let exerciseRepository: ExerciseRepository

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.exerciseRepository = .init(viewContext: context)
        fetchExercises()
    }

    func fetchExercises() {
        do {
            let exercisesFromDB = try exerciseRepository.getExercises()
            exercises = exercisesFromDB
        } catch {
            showAlert = true
            alertReason = .fetchCoreDataFailed(" Not able to fetch exercises: \(error.localizedDescription)")
        }
    }
    
    func deleteExercise(at offset: IndexSet) {
        let selectedExercises = offset.map { exercises[$0] }
        exerciseRepository.delete(exercises: selectedExercises)
        fetchExercises()
    }
}
