//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddExerciseViewModel
    
    @State private var duration = ""
    @State private var intensity = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Catégorie", text: $viewModel.category)
                    DatePicker(
                        "Heur de démarrage",
                        selection: $viewModel.startTime,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    TextField("Durée (en minutes)", text: $duration)
                        .onChange(of: duration) {
                            viewModel.duration = Int(duration) ?? 0
                        }
                    TextField("Intensité (0 à 10)", text: $intensity)
                        .onChange(of: intensity) {
                            viewModel.intensity = Int(intensity) ?? 0
                        }
                }.formStyle(.grouped)
                Spacer()
                Button("Ajouter l'exercice") {
                    if viewModel.addExercise() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }.buttonStyle(.borderedProminent)
                    
            }
            .navigationTitle("Nouvel Exercice ...")
            .alert(
                "Error to load exercise datas.",
                isPresented: $viewModel.showAlert,
                presenting: viewModel.alertReason.failureReason,
                actions: { reason in
                    Button("OK", role: .cancel) { }
                },
                message: { reason in
                    Text(reason)
                }
            )
            
        }
    }
}

#Preview {
    AddExerciseView(viewModel: AddExerciseViewModel(context: PersistenceController.preview.container.viewContext))
}
