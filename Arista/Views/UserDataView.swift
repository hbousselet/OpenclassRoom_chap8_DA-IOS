//
//  UserDataView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct UserDataView: View {
    @ObservedObject var viewModel: UserDataViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text("Hello")
                .font(.largeTitle)
            Text("\(viewModel.firstName) \(viewModel.lastName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .alert(
            "Error to load user datas.",
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

#Preview {
    UserDataView(viewModel: UserDataViewModel(context: PersistenceController.preview.container.viewContext))
}
