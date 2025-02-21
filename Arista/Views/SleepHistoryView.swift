//
//  SleepHistoryView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct SleepHistoryView: View {
    @ObservedObject var viewModel: SleepHistoryViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.sleepSessions) { session in
                HStack {
                    QualityIndicator(quality: Int(session.quality))
                        .padding()
                    VStack(alignment: .leading) {
                        if let date = session.startDate {
                            Text(date.formatted(.dateTime
                                .day()
                                .month(.wide)
                                .weekday(.wide)
                                .hour(.conversationalTwoDigits(amPM: .wide))
                                .minute(.twoDigits)
                                .locale(Locale(identifier: "fr_FR"))))
                        }
                        Text("Durée : \(session.duration/60) heures")
                    }
                }
            }
            
            .navigationTitle("Sleep History")
            .alert(
                "Error to load sleep datas.",
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
                await viewModel.fetchSleepSessions()
            }
        }
    }
}

struct QualityIndicator: View {
    let quality: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(qualityColor(quality), lineWidth: 5)
                .foregroundColor(qualityColor(quality))
                .frame(width: 30, height: 30)
            Text("\(quality)")
                .foregroundColor(qualityColor(quality))
        }
    }

    func qualityColor(_ quality: Int) -> Color {
        switch (10-quality) {
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
