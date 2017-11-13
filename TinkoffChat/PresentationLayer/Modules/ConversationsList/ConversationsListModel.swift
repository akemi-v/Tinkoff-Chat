//
//  ConversationsListModel.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IConversationsListModel : class {
    weak var delegate : IConversationsListModelDelegate? { get set }
    var communicationService : ICommunicatorDelegate? { get set }
    var storageService : (IDataManager & IStorageManager)? { get set }
    
    func getConversations() -> [ConversationsListCellData]
    func clearConversations()
}

protocol IConversationsListModelDelegate : class {
    func setup(dataSource: [ConversationsListCellData])
}

class ConversationsListModel : IConversationsListModel {
    weak var delegate: IConversationsListModelDelegate? 
    var communicationService: ICommunicatorDelegate?
    var storageService : (IDataManager & IStorageManager)?
    
    init(communicationService: ICommunicatorDelegate, storageService: (IDataManager & IStorageManager)) {
        self.communicationService = communicationService
        self.communicationService?.delegate = self
        
        self.storageService = storageService
    }
    
    func getConversations() -> [ConversationsListCellData] {
        if let manager = communicationService {
            let sortedConversations = sortConversationsListByDateThenName(conversations: manager.conversations)
            manager.conversations = sortedConversations
            return manager.conversations
        }
        return []
    }
    
    func clearConversations() {
        communicationService?.conversations.removeAll()
    }
    
    private func sortConversationsListByDateThenName(conversations: [ConversationsListCellData]) -> [ConversationsListCellData] {
        
        let sortedConversations = conversations.sorted(by: {
            if $0.date ?? Date(timeIntervalSince1970: 0) != $1.date ?? Date(timeIntervalSince1970: 0) {
                return $0.date ?? Date(timeIntervalSince1970: 0) > $1.date ?? Date(timeIntervalSince1970: 0)
            } else {
                return $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? ""
            }
        })
        return sortedConversations
        
    }
}

extension ConversationsListModel : ICommunicationManagerDelegate {
    func reloadData() {
        (self.delegate as? ConversationsListViewController)?.setup(dataSource: getConversations())
    } 
}
