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

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func addExercise() -> Bool {
        do {
            try Exercise.saveExercise(context: viewContext,
                                      category: category,
                                      duration: duration,
                                      intensity: intensity,
                                      startDate: startTime)
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
