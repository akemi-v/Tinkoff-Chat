//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/19/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

protocol ICommunicatorDelegate : class {
    //discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    
    var conversations : [ConversationsListCellData] { get set }
    var conversationMessages : [String: [ConversationCellData]] { get set }
    var delegate: ICommunicationManagerDelegate? { get set }
}

protocol ICommunicationManagerDelegate : class {
    func reloadData()
}

protocol IHavingSendButton : class {
    func enableSendButton(enable: Bool)
}

class CommunicationManager: ICommunicatorDelegate {
    var delegate: ICommunicationManagerDelegate?
    
    private var communicator : ICommunicator?
    private var storage : IStorageManager?

    var conversations : [ConversationsListCellData] = []
    var conversationMessages : [String: [ConversationCellData]] = [:]
    
    
    init(communicator: ICommunicator, storage: IStorageManager) {
        self.communicator = communicator
        self.communicator?.delegate = self
        
        self.storage = storage
        self.storage?.setAllConversationsOffline()
    }
    
    func didFoundUser(userID: String, userName: String?) {
        
        storage?.setOnlineConversation(userID: userID, userName: userName)

        self.delegate?.reloadData()
        if let delegateVC = self.delegate as? IHavingSendButton {
            delegateVC.enableSendButton(enable: true)
        }
    }
    
    func didLostUser(userID: String) {        
        
        storage?.setOfflineConversation(userID: userID)
        
        self.delegate?.reloadData()
        if let delegateVC = self.delegate as? IHavingSendButton {
            delegateVC.enableSendButton(enable: false)
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        
    }
    
    func failedToStartAdvertising(error: Error) {
        
    }

    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        
        conversations.enumerated().forEach({ (index, conversation) in
            if fromUser == conversation.ID {
                conversations[index].message = text
                conversations[index].date = Date()
                conversations[index].hasUnreadMessages = true
                conversations[index].lastIncoming = true
            }
        })
        
        if conversationMessages[fromUser] == nil {
            conversationMessages[fromUser] = []
        }
        
        if var messages = conversationMessages[fromUser] {
            messages.insert(ConversationCellData(identifier: "Incoming Message Cell ID", textMessage: text), at: 0)
            conversationMessages[fromUser] = messages
        }
        
        
        
        self.delegate?.reloadData()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?) {
        communicator?.sendMessage(string: string, to: userID, completionHandler: completionHandler)
        self.delegate?.reloadData()
    }
    
}
