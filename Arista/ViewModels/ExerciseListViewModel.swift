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

    let exerciseRepository: ExerciseRepository

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.exerciseRepository = .init(viewContext: context)
    }

//    func fetchExercises() {
//        do {
//            let exercisesFromDB = try exerciseRepository.getExercises()
//            exercises = exercisesFromDB
//        } catch {
//            showAlert = true
//            alertReason = .fetchCoreDataFailed(" Not able to fetch exercises: \(error.localizedDescription)")
//        }
//    }
    
    func deleteExercise(at offset: IndexSet) {
        let selectedExercises = offset.map { exercises[$0] }
        
        Task {
            await exerciseRepository.deleteAsync(exercises: selectedExercises)
            await fetchExercises()
        }
    }
    
    func fetchExercises() async {
        Task {
            do {
                guard let exercices = try await exerciseRepository.getExercisesAsync() else {
                    exercises = []
                    return
                }
                exercises = exercices
            } catch {
                showAlert = true
                alertReason = .fetchCoreDataFailed(" Not able to fetch your exercises datas: \(error.localizedDescription)")
            }
        }
    }
}
