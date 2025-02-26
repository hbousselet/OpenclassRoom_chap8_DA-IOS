//
//  TestPersistenceController.swift
//  AristaTests
//
//  Created by Hugues BOUSSELET on 25/02/2025.
//

@testable import Arista
import Foundation
import CoreData

//class TestPersistenceController: PersistenceController {
//  override init() {
//    super.init()
//
//    let persistentStoreDescription = NSPersistentStoreDescription()
//    persistentStoreDescription.type = NSInMemoryStoreType
//
//    let container = NSPersistentContainer(
//      name: PersistenceController.modelName,
//      managedObjectModel: PersistenceController.model(name: PersistenceController.modelName))
//    
//      container.persistentStoreDescriptions = [persistentStoreDescription]
//
//    container.loadPersistentStores { _, error in
//      if let error = error as NSError? {
//        fatalError("Unresolved error \(error), \(error.userInfo)")
//      }
//    }
//
//    storeContainer = container
//  }
//}
