//
//  ConversationDataProvider.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/11/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ConversationDataProvider : NSObject, IDataProvider {
    
    let fetchedResultsController : NSFetchedResultsController<Message>
    let tableView : UITableView
    var storage: IStorageManager
    let conversationId : String
    
    init?(tableView: UITableView, conversationId: String, storage: IStorageManager) {
        self.tableView = tableView
        self.storage = storage
        self.conversationId = conversationId
        
        
        guard let context = storage.stack.mainContext else { return nil }
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Empty managed object model")
            return nil
        }
        
        guard let fetchRequest = Message.fetchRequestMessagesFromConversation(conversationId: conversationId, model: model) else {
            print("Fetch request doesn't exist")
            return nil
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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

extension ConversationDataProvider : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
