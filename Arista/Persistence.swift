//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import CoreData

class PersistenceController {
    private static var _model: NSManagedObjectModel?
    
    public static let modelName = "Arista"
    
    public static func model(name: String) -> NSManagedObjectModel {
        guard let _model = loadModel(name: name, bundle: Bundle.main) else {
            print("error bla")
            return NSManagedObjectModel()
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
        let container = NSPersistentContainer(name: PersistenceController.modelName,
                                              managedObjectModel: PersistenceController.model(name: PersistenceController.modelName))
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return container
    }()
        
    var context: NSManagedObjectContext {
        return Self.container.viewContext
    }
}


//public extension NSManagedObject {
//    convenience init(context: NSManagedObjectContext) {
//        let name = String(describing: type(of: self))
//        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
//        self.init(entity: entity, insertInto: context)
//    }
//}
