//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel: ExerciseListViewModel
    @State private var showingAddExerciseView = false
        
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.exercises) { exercise in
                    HStack {
                        Image(systemName: iconForCategory(exercise.category ?? "questionmark"))
                        VStack(alignment: .leading) {
                            Text(exercise.category ?? "Unknown")
                                .font(.headline)
                            Text("Durée: \(exercise.duration) min")
                                .font(.subheadline)
                            Text(exercise.startDate?.formatted() ?? "not found")
                                .font(.subheadline)
                            
                        }
                        Spacer()
                        IntensityIndicator(intensity: Int(exercise.intensity))
                    }
                }
                .onDelete { indexSet in
                    withAnimation {
                        deleteRow(with: indexSet)
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.fetchExercises()
                }
            }
            .navigationTitle("Exercices")
            .navigationBarItems(trailing: Button(action: {
                showingAddExerciseView = true
            }) {
                Image(systemName: "plus")
            })
            
            .sheet(isPresented: $showingAddExerciseView, onDismiss: {
                Task {
                    await viewModel.fetchExercises()
                }
            }) {
                AddExerciseView(viewModel: AddExerciseViewModel())
            }
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
            .task {
                await viewModel.fetchExercises()
            }
        }
    }
    
    func iconForCategory(_ category: String) -> String {
        switch category {
        case "Football":
            return "sportscourt"
        case "Natation":
            return "waveform.path.ecg"
        case "Running":
            return "figure.run"
        case "Marche":
            return "figure.walk"
        case "Cyclisme":
            return "bicycle"
        default:
            return "questionmark"
        }
    }
    
    private func deleteRow(with indexSet: IndexSet) {
        Task {
            await viewModel.deleteExercise(at: indexSet)
        }
    }
}

struct IntensityIndicator: View {
    var intensity: Int
    
    var body: some View {
        Circle()
            .fill(colorForIntensity(intensity))
            .frame(width: 10, height: 10)
    }
    
    func colorForIntensity(_ intensity: Int) -> Color {
        switch intensity {
        case 0...3:
            return .green
        case 4...6:
            return .yellow
        case 7...10:
            return .red
        default:
            return .gray
        }
    }
}
