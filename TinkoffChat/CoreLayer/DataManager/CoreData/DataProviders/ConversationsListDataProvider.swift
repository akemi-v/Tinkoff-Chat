//
//  ConversationsListDataProvider.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/11/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ConversationsListDataProvider : NSObject, IDataProvider {
    
    let fetchedResultsController : NSFetchedResultsController<Conversation>
    let tableView : UITableView
    var storage : IStorageManager
    
    init?(tableView: UITableView, storage: IStorageManager) {
        self.tableView = tableView
        self.storage = storage
        
        //        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        guard let context = storage.stack.mainContext else { return nil }
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Empty managed object model")
            return nil
        }
        
        guard let fetchRequest = Conversation.fetchRequestConversationsList(model: model) else {
            print("Fetch request doesn't exist")
            return nil
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "isOnline", cacheName: nil)
        print(fetchedResultsController.sections?.count)
        super.init()
        fetchedResultsController.delegate = self
        self.fetchResults()
    }
    
    func fetchResults() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching: \(error)")
        }
    }
}

extension ConversationsListDataProvider : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        DispatchQueue.main.async {
            self.tableView.beginUpdates()
//        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        DispatchQueue.main.async {
            self.tableView.endUpdates()
//        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
//                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                }
            }
        case .insert:
            if let newIndexPath = newIndexPath {
//                DispatchQueue.main.async {
                    self.tableView.insertRows(at: [newIndexPath], with: .automatic)
//                }
            }
        case .move:
            if let indexPath = indexPath {
//                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                }
            }
            
            if let newIndexPath = newIndexPath {
//                DispatchQueue.main.async {
                    self.tableView.insertRows(at: [newIndexPath], with: .automatic)
//                }
            }
        case .update:
            if let indexPath = indexPath {
//                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
//                }
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
//            DispatchQueue.main.async {
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
//            }
        case .insert:
//            DispatchQueue.main.async {
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
//            }
        case .move, .update:
            break
        }
    }
}
