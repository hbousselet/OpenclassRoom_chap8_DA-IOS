//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

@MainActor
class SleepHistoryViewModel: ObservableObject {
    @Published var sleepSessions = [Sleep]()
    
    var showAlert: Bool = false
    var alertReason: ErrorHandler = .none
    let sleepRepository: SleepRepository?
    
    init(sleepRepository: SleepRepository? = SleepRepository(viewContext: PersistenceController.shared.context)) {
        self.sleepRepository = sleepRepository
        if self.sleepRepository == nil {
            self.showAlert = true
            self.alertReason = .cantLoadRepository("Not able to load CoreData")
        }
    }
    
    func fetchSleepSessions() async {
        do {
            let sleeps = try await sleepRepository?.get()
            sleepSessions = sleeps ?? []
        } catch {
            showAlert = true
            alertReason = .fetchCoreDataFailed(" Not able to fetch your sleep datas: \(error.localizedDescription)")
        }
    }
}
