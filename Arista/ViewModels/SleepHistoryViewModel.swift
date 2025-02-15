//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class SleepHistoryViewModel: ObservableObject {
    @Published var sleepSessions = [Sleep]()
    
    var showAlert: Bool = false
    var alertReason: ErrorHandler = .none
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchSleepSessions()
    }
    
    private func fetchSleepSessions() {
        do {
            let sleeps = try Sleep.getSleeps(context: viewContext)
            sleepSessions = sleeps
        } catch {
            showAlert = true
            alertReason = .fetchCoreDataFailed(" Not able to fetch your sleep datas: \(error.localizedDescription)")
        }
    }
}
