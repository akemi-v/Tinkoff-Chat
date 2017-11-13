//
//  Message.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/11/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import CoreData

extension Message {
    static func fetchRequestMessagesFromConversation(conversationId: String, model: NSManagedObjectModel) -> NSFetchRequest<Message>? {
        let templateName = "MessagesFromConversationWithId"
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["CONVERSATIONID": conversationId]) as? NSFetchRequest<Message> else {
            assert(false, "No template with name \(templateName)")
            return nil
        }
        
        return fetchRequest
    }
    
    static func insertMessage(incoming: Bool, text: String, in context: NSManagedObjectContext) -> Message? {
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message {
            message.messageId = generateMessageIdString()
            message.date = Date()
            message.incoming = incoming
            message.text = text
            
            return message
        }
        
        return nil
    }
    
    static func generateMessageIdString() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }



}
