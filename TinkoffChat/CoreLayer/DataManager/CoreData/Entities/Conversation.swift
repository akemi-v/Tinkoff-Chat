//
//  Conversation.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/11/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Conversation {
    static func fetchRequestConversationsList(model: NSManagedObjectModel) -> NSFetchRequest<Conversation>? {
        let templateName = "Conversations"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName)?.copy() as? NSFetchRequest<Conversation> else {
            assert(false, "No template with name \(templateName)")
            return nil
        }
        
        let sortByOnline = NSSortDescriptor(key: "isOnline", ascending: false)
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByOnline, sortByDate, sortByName]
        
        return fetchRequest
    }
    
    static func fetchRequestConversationWithUser(userId: String, model: NSManagedObjectModel) -> NSFetchRequest<Conversation>? {
        let templateName = "ConversationWithUser"
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["USERID": userId]) as? NSFetchRequest<Conversation> else {
            assert(false, "No template with name \(templateName)")
            return nil
        }
        
        return fetchRequest
    }
    
    static func findOrInsertConversation(userId: String, name: String, in context: NSManagedObjectContext) -> Conversation? {
            guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
                print("Model is not available in context!")
                assert(false)
                return nil
            }
    
            var conversation : Conversation?
    
            guard let fetchRequest = Conversation.fetchRequestConversationWithUser(userId: userId, model: model) else {
                return nil
            }
    
            do {
                let results = try context.fetch(fetchRequest)
                assert(results.count < 2, "Multiple Conversations found!")
                if let foundConversation = results.first {
                    conversation = foundConversation
                }
            } catch {
                print("Failed to fetch Conversation: \(error)")
            }
    
            if conversation == nil {
                conversation = Conversation.insertConversation(in: context)
                conversation?.participant = User.findOrInsertUser(userId: userId, name: name, in: context)
                conversation?.name = name
            }
            
        
    
            return conversation
        }
    
    static func insertConversation(in context: NSManagedObjectContext) -> Conversation? {
        if let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation {
            conversation.conversationId = generateConversationIdString()
            
            return conversation
        }
        
        return nil
    }
    
    static func findAllConversations(in context: NSManagedObjectContext) -> [Conversation] {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return []
        }
        
        var conversations : [Conversation] = []
        
        guard let fetchRequest = Conversation.fetchRequestConversationsList(model: model) else {
            return []
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            conversations = results
        } catch {
            print("Failed to fetch Conversation: \(error)")
        }
        
        return conversations
    }
    
    static func generateConversationIdString() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
}
