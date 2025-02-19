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
            sayHello
                .padding(.top, 5)
            clockMaker()
                .padding(.top, 50)
            userData
                .padding(.top, 40)
            tips
                .padding(.top, 20)
        }
        .safeAreaPadding(.top)
        .padding(.horizontal, 20)
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
    
    var sayHello: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today")
                    .font(.headline)
                Text("Good morning, \(viewModel.firstName)")
                    .font(.headline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Image("image_avatar")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 50.0)
                .padding()
        }
    }
    
    @ViewBuilder
    func clockMaker() -> some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: 25)
                    .foregroundStyle(.gray).opacity(0.1)
                    .position(UserDataViewModel.Position.zero.in(geometry))
                ZStack(alignment: .top) {
                    Circle()
                        .trim(from: 0.0, to: 0.66)
                        .stroke(.blue, style: StrokeStyle(
                            lineWidth: 25.0,
                            lineCap: .round,
                            lineJoin: .miter))
                        .rotationEffect(Angle(degrees: -90))
                        .shadow(radius: 10)
                        .zIndex(1)
                        .position(UserDataViewModel.Position.zero.in(geometry))
                    Image(systemName: "plus")
                        .tint(.red)
                        .zIndex(2)
                        .position(viewModel.wakeUpTimeImagePosition.in(geometry))
                }
                Image("clock")
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .position(UserDataViewModel.Position.zero.in(geometry))
            }
            .onAppear {
                if geometry.size.height > geometry.size.width {
                    viewModel.radius = geometry.size.width / 2
                } else {
                    viewModel.radius = geometry.size.width / 2
                }
                viewModel.reComputePosition()
            }
//            .padding(.horizontal)
        }
    }
    
    var userData: some View {
        HStack {
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(.blue)
                    Text("Bedtime")
                        .font(.headline)
                }
                Text("00.00")
                    .font(.system(size: 12.0, weight: .heavy))
                
            }
            .padding(.leading, 5)
            Spacer()
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: "alarm.fill")
                        .foregroundStyle(.yellow)
                    Text("Alarm")
                        .font(.headline)
                }
                Text("08.00")
                    .font(.system(size: 12.0, weight: .heavy))
                
            }
            Spacer()
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: "bed.double.circle.fill")
                        .foregroundStyle(.green)
                    Text("Siesta")
                        .font(.headline)
                }
                Text("12.50")
                .font(.system(size: 12.0, weight: .heavy))            }
            .padding(.trailing, 5)
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(minHeight: 60)
            }
            .foregroundColor(.teal).opacity(0.3)
        }
    }
    
    @ViewBuilder
    var tips: some View {
        VStack(alignment: .leading) {
            Text(" MYTH OR REALITY")
                .font(.headline)
                .padding(.top)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .lightGray))
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("1. I need to sleep at least 7 hours a night.")
                                .font(.caption)
                            Button {
                                
                            } label: {
                                Text("FIND OUT")
                                    .padding()
                                    .foregroundStyle(.white)
                                    .background(.blue)
                                    .clipShape(.capsule(style: .circular))
                            }
                            .padding(.vertical, 5)
                        }
                        .padding(.leading, 5)
                        Spacer()
                        Image("panda")
                            .resizable()
                            .frame(width: 65, height: 65)
                            .padding()
                    }
                }
                .frame(height: 100)
                .foregroundStyle(.background)
        }
    }
    
//    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
//        let center = geometry.frame(in: .local).center
//        return Emoji.Position(
//            x: Int((location.x - center.x - pan.width) / zoom),
//            y: Int(-(location.y - center.y - pan.height) / zoom)
//        )
//    }
}

#Preview {
    UserDataView(viewModel: UserDataViewModel(context: PersistenceController.preview.container.viewContext))
}
