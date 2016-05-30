//
//  CoreDataManager.swift
//  StickerApp
//
//  Created by Nate Parrott on 9/6/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit
import CoreData

var _SharedCoreDataManager: CoreDataManager?
func SharedCoreDataManager() -> CoreDataManager {
    if _SharedCoreDataManager == nil {
        _SharedCoreDataManager = CoreDataManager()
    }
    return _SharedCoreDataManager!
}

class CoreDataManager: NSObject {
    override init() {
        super.init()
    }
    @objc func getShared() -> CoreDataManager { // because fuck swift
        return SharedCoreDataManager()
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("InstaGrade", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    var storageURL: NSURL {
        get {
            let libraryUrl = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first! as NSURL
            let url = libraryUrl.URLByAppendingPathComponent("InstaGrade.sqlite")
            return url
        }
    }
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storageURL, options: nil)
        } catch _ {
            print("ERROR: Failed to initialize the application's saved data")
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch _ {
                    print("ERROR saving managed object context")
                    abort()
                }
            }
        }
    }
    
    @objc func newEntity(name: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(name, inManagedObjectContext: managedObjectContext!) as NSManagedObject
    }
    
    func blobForImage(image: UIImage) -> NSManagedObject {
        let obj = newEntity("Image")
        obj.setValue(UIImagePNGRepresentation(image), forKey: "data")
        return obj
    }
    
    func save() {
        saveContext()
    }
    
    func deleteEntities(name: String) {
        let req = NSFetchRequest(entityName: name)
        req.includesPropertyValues = false
        for obj in try! managedObjectContext!.executeFetchRequest(req) as! [NSManagedObject] {
            managedObjectContext!.deleteObject(obj)
        }
    }
}
