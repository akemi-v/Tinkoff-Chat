//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/19/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

protocol CommunicatorDelegate : class {
    //discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}

class CommunicationManager: NSObject, CommunicatorDelegate {
    
    static let shared = CommunicationManager()
    
    weak var conversationsListVC : ConversationsListViewController?
    weak var conversationVC : ConversationViewController?
    
    func didFoundUser(userID: String, userName: String?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationInfoUser"), object: true)
        
        self.conversationsListVC?.conversations.append(ConversationsListCellData(ID: userID, name: userName, message: nil, date: nil, online: true, hasUnreadMessages: false, lastIncoming: true))

        if let sortedConversations = sortConversationsListByDateThenName(conversations: self.conversationsListVC?.conversations) {
            self.conversationsListVC?.conversations = sortedConversations
        }
            
        DispatchQueue.main.async {
            self.conversationsListVC?.tableView.reloadData()
        }
    }
    
    func didLostUser(userID: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationInfoUser"), object: false)
        
        if let enumConversations = self.conversationsListVC?.conversations.enumerated() {
            for (index, conversation) in enumConversations {
                if userID == conversation.ID {
                    self.conversationsListVC?.conversations.remove(at: index)
                    break
                }
            }
        }
        
        DispatchQueue.main.async {
            self.conversationsListVC?.tableView.reloadData()
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        
    }
    
    func failedToStartAdvertising(error: Error) {
        
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        guard let conversations = self.conversationsListVC?.conversations.enumerated() else { return }
        
        for (index, conversation) in conversations {
            if fromUser == conversation.ID {
                self.conversationsListVC?.conversations[index].message = text
                self.conversationsListVC?.conversations[index].date = Date()
                self.conversationsListVC?.conversations[index].hasUnreadMessages = true
                self.conversationsListVC?.conversations[index].lastIncoming = true
            }
        }
        
        if self.conversationsListVC?.conversationMessages[fromUser] == nil {
            self.conversationsListVC?.conversationMessages[fromUser] = []
        }
        
        if var messages = self.conversationsListVC?.conversationMessages[fromUser] {
            messages.insert(ConversationCellData(identifier: "Incoming Message Cell ID", textMessage: text), at: 0)
            self.conversationsListVC?.conversationMessages[fromUser] = messages
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messagesUpdated"), object: nil)
        
        if let sortedConversations = sortConversationsListByDateThenName(conversations: self.conversationsListVC?.conversations) {
            self.conversationsListVC?.conversations = sortedConversations
        }
        
        DispatchQueue.main.async {
            self.conversationsListVC?.tableView.reloadData()
        }
    }
    
}
