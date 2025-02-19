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
    
    let sleepRepository: SleepRepository
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.sleepRepository = SleepRepository(viewContext: context)
        fetchSleepSessions()
    }
    
    private func fetchSleepSessions() {
        Task {
            do {
                guard let sleeps = try await sleepRepository.getSleepsAsync() else {
                    sleepSessions = []
                    return
                }
                sleepSessions = sleeps
            } catch {
                showAlert = true
                alertReason = .fetchCoreDataFailed(" Not able to fetch your sleep datas: \(error.localizedDescription)")
            }
        }
    }
}
