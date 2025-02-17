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
    
    private var viewContext: NSManagedObjectContext
    let sleepRepository: SleepRepository
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.sleepRepository = SleepRepository(viewContext: viewContext)
        fetchSleepSessions()
    }
    
    private func fetchSleepSessions() {
        Task {
            do {
                let sleeps = try await sleepRepository.getSleepsAsync()
                sleepSessions = sleeps
            } catch {
                showAlert = true
                alertReason = .fetchCoreDataFailed(" Not able to fetch your sleep datas: \(error.localizedDescription)")
            }
        }
    }
}
