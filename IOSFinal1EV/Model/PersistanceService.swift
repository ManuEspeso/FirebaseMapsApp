//
//  PersistanceService.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 03/12/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import CoreData

class PersistenceService {
    
    private init (){}
    
    static var context: NSManagedObjectContext {
        return persistanceContainer.viewContext
    }
    
    static var persistanceContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {(storeDescription, err) in
            
            if let err = err as NSError? {
                print("Unresolved error \(err), \(err.userInfo)")
            }
        })
        return container
    }()
    
    static func saveContext() -> Bool {
        
        let context = persistanceContainer.viewContext
        
        if context.hasChanges {
            do {
                
                try context.save()
                return true
            } catch {
                
                let nserror = error as NSError
                print("Unresolved error \(error), \(nserror.userInfo)")
                return false
            }
        } else {
            return false
        }
    }
}
