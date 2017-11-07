//
//  CoreDataStack.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/2/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit
import CoreData

protocol ICoreDataStack : class {
    var masterContext: NSManagedObjectContext? { get }
    var mainContext: NSManagedObjectContext? { get }
    var saveContext: NSManagedObjectContext? { get }
    func performSave(context: NSManagedObjectContext, completionHandler: ((Bool) -> Void)?)
}


class CoreDataStack: NSObject, ICoreDataStack {
    private var storeURL : URL {
        get {
            let documentsDirUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentsDirUrl.appendingPathComponent("Store.sqlite")
            
            return url
        }
    }
    
    private let managedObjectModelName = "TinkoffChat"
    private var _managedObjectModel : NSManagedObjectModel?
    private var managedObjectModel : NSManagedObjectModel? {
        get {
            if _managedObjectModel == nil {
                guard let modelURL = Bundle.main.url(forResource: managedObjectModelName, withExtension: "momd") else {
                    print("Empty model url!")
                    return nil
                }
                
                _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            }
            
            return _managedObjectModel
        }
    }
    
    private var _persistentStoreCoordinator : NSPersistentStoreCoordinator?
    private var persistentStoreCoordinator : NSPersistentStoreCoordinator? {
        get {
            if _persistentStoreCoordinator == nil {
                guard let model = self.managedObjectModel else {
                    print("Empty managed object model")
                    return nil
                }
                
                _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                do {
                    try _persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                        configurationName: nil,
                                                                        at: storeURL,
                                                                        options: nil)
                } catch {
                    assert(false, "Error adding persistent store to coordinator: \(error)")
                }
            }
            
            return _persistentStoreCoordinator
        }
    }
    
    private var _masterContext : NSManagedObjectContext?
    public var masterContext : NSManagedObjectContext? {
        get {
            if _masterContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
                    print("Empty persistent store coordinator!")
                    return nil
                }
                
                context.persistentStoreCoordinator = persistentStoreCoordinator
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _masterContext = context
            }
            
            return _masterContext
        }
    }
    
    private var _mainContext : NSManagedObjectContext?
    public var mainContext : NSManagedObjectContext? {
        get {
            if _mainContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                guard let parentContext = self.masterContext else {
                    print("No master context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _mainContext = context
            }
            
            return _mainContext
        }
    }
    
    private var _saveContext : NSManagedObjectContext?
    public var saveContext : NSManagedObjectContext? {
        get {
            if _saveContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                guard let parentContext = self.mainContext else {
                    print("No main context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _saveContext = context
            }
            
            return _saveContext
        }
    }
    
    public func performSave(context: NSManagedObjectContext, completionHandler: ((Bool) -> Void)?) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                }
                catch {
                    print("Context save error: \(error)")
                    completionHandler?(false)
                }
                
                if let parent = context.parent {
                    self?.performSave(context: parent, completionHandler: completionHandler)
                } else {
                    completionHandler?(true)
                }
            }
        } else {
            completionHandler?(true)
        }
    }
}
