//
//  ConversationModel.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IConversationModel : class {
    weak var delegate : IConversationModelDelegate? { get set }
    var communicationService : ICommunicatorDelegate? { get set }
    var userId : String? { get set }
    var storageService : (IDataManager & IStorageManager)? { get set }
    
    func getMessages() -> [ConversationCellData]
    func markConversationAsRead()
    func updateConversationMessages(with messages: [ConversationCellData])
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?)
    func updateConversationData(with text: String)
}

protocol IConversationModelDelegate : class {
    func setup(dataSource: [ConversationCellData])
}

class ConversationModel : IConversationModel {
    
    weak var delegate: IConversationModelDelegate?
    var communicationService: ICommunicatorDelegate?
    var conversations: [ConversationCellData] = []
    var userId: String?
    var storageService: (IDataManager & IStorageManager)?

    
    init(communicationService: ICommunicatorDelegate, storageService: (IDataManager & IStorageManager)) {
        self.communicationService = communicationService
        self.communicationService?.delegate = self
        
        self.storageService = storageService
    }
    
    func getMessages() -> [ConversationCellData] {
        guard let unwrappedUserId = userId else { return [] }
        if let manager = communicationService {
            return manager.conversationMessages[unwrappedUserId] ?? []
        }
        return []
    }
    
    func markConversationAsRead() {
        communicationService?.conversations.enumerated().forEach({ (index, conversation) in
            if userId == conversation.ID {
                communicationService?.conversations[index].hasUnreadMessages = false
            }
        })
    }
    
    func updateConversationMessages(with messages: [ConversationCellData]) {
        guard let userIdUnwrapped = userId else { return }
        communicationService?.conversationMessages[userIdUnwrapped] = messages
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        communicationService?.sendMessage(string: string, to: userID, completionHandler: completionHandler)
    }
    
    func updateConversationData(with text: String) {
        communicationService?.conversations.enumerated().forEach({ (index, conversation) in
            if userId == conversation.ID {
                communicationService?.conversations[index].hasUnreadMessages = false
                communicationService?.conversations[index].message = text
                communicationService?.conversations[index].date = Date()
                communicationService?.conversations[index].lastIncoming = false
            }
            
        })

    }
    
}

extension ConversationModel : ICommunicationManagerDelegate, IHavingSendButton {
    func reloadData() {
        (self.delegate as? ConversationViewController)?.dataProvider?.fetchResults()
    }
    
    func enableSendButton(enable: Bool) {
        (self.delegate as? ConversationViewController)?.enableSendButton(enable: enable)
        
    }
}
