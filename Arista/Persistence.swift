//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import CoreData

struct PersistenceController {
    private static var _model: NSManagedObjectModel?
    
    private static func model(name: String) -> NSManagedObjectModel {
        guard let _model = loadModel(name: name, bundle: Bundle.main) else {
            fatalError("Unable to load managed object model")
        }
        return _model
    }
    private static func loadModel(name: String, bundle: Bundle) -> NSManagedObjectModel? {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            return nil
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        return model
    }
    
    private init() {}
    
    static var shared = PersistenceController()
    
    private static var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Arista", managedObjectModel: PersistenceController.model(name: "Arista"))
        if shared.isInMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return container
    }()
    
    var isInMemory: Bool = false
    
    var context: NSManagedObjectContext {
        return Self.container.viewContext
    }
}


public extension NSManagedObject {
  convenience init(using usedContext: NSManagedObjectContext) {
    let name = String(describing: type(of: self))
    let entity = NSEntityDescription.entity(forEntityName: name, in: usedContext)!
    self.init(entity: entity, insertInto: usedContext)
  }
}
