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

    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.exerciseRepository = .init(viewContext: context)
    }
    
    func deleteExercise(at offset: IndexSet) async {
        let selectedExercises = offset.map { exercises[$0] }
        await exerciseRepository.deleteAsync(exercises: selectedExercises)
        await fetchExercises()
    }
    
    func fetchExercises() async {
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
