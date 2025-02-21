////
////  DefaultDatas.swift
////  Arista
////
////  Created by Hugues BOUSSELET on 15/02/2025.
////
//
//import Foundation
//import CoreData
//
//
//struct DefaultData {
//    
//    func apply() throws {
//
//        if (try UserRepository(viewContext: PersistenceControllerDue.shared.container.viewContext).getUser() ) == nil {
//            let initialUser = User(context: PersistenceControllerDue.shared.container.viewContext)
//            initialUser.firstName = "Charlotte"
//            initialUser.lastName = "Razoul"
//            initialUser.password = "blabla"
//            initialUser.email = "charlotte.razoul@gmail.com"
//            
//            if try SleepRepository(viewContext: PersistenceControllerDue.shared.container.viewContext).getSleeps().isEmpty {
//                let sleep1 = Sleep(context: PersistenceControllerDue.shared.container.viewContext)
//                let sleep2 = Sleep(context: PersistenceControllerDue.shared.container.viewContext)
//                let sleep3 = Sleep(context: PersistenceControllerDue.shared.container.viewContext)
//                let sleep4 = Sleep(context: PersistenceControllerDue.shared.container.viewContext)
//                let sleep5 = Sleep(context: PersistenceControllerDue.shared.container.viewContext)
//                
//                let timeIntervalForADay: TimeInterval = 60 * 60 * 24
//                
//                sleep1.duration = (0...900).randomElement()!
//                sleep1.quality = (0...10).randomElement()!
//                sleep1.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*5)
//                sleep1.user = initialUser
//                
//                sleep2.duration = (0...900).randomElement()!
//                sleep2.quality = (0...10).randomElement()!
//                sleep2.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*4)
//                sleep2.user = initialUser
//                
//                sleep3.duration = (0...900).randomElement()!
//                sleep3.quality = (0...10).randomElement()!
//                sleep3.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*3)
//                sleep3.user = initialUser
//                
//                sleep4.duration = (0...900).randomElement()!
//                sleep4.quality = (0...10).randomElement()!
//                sleep4.startDate = Date(timeIntervalSinceNow: timeIntervalForADay*2)
//                sleep4.user = initialUser
//                
//                sleep5.duration = (0...900).randomElement()!
//                sleep5.quality = (0...10).randomElement()!
//                sleep5.startDate = Date(timeIntervalSinceNow: timeIntervalForADay)
//                sleep5.user = initialUser
//            }
//            
//            try? PersistenceControllerDue.shared.container.viewContext.save()
//        }
//        
//    }
//}
