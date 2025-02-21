//
//  AristaApp.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

@main
struct AristaApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TabView {
                UserDataView(viewModel: UserDataViewModel(context: PersistenceController.shared.context))
                    .environment(\.managedObjectContext, PersistenceController.shared.context)
                    .tabItem {
                        Label("Utilisateur", systemImage: "person")
                    }
                
                ExerciseListView(viewModel: ExerciseListViewModel(context: PersistenceController.shared.context))
                    .environment(\.managedObjectContext, PersistenceController.shared.context)
                    .tabItem {
                        Label("Exercices", systemImage: "flame")
                    }
                
                SleepHistoryView(viewModel: SleepHistoryViewModel(context: PersistenceController.shared.context))
                    .environment(\.managedObjectContext, PersistenceController.shared.context)
                    .tabItem {
                        Label("Sommeil", systemImage: "moon")
                    }
            }
        }
    }
}
