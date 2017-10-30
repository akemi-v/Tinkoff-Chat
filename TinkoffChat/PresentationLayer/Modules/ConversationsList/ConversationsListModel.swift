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
    var communicationService : CommunicatorDelegate? { get set }
    
    func getConversations() -> [ConversationsListCellData]
}

protocol IConversationsListModelDelegate : class {
    func setup(dataSource: [ConversationsListCellData])
}

class ConversationsListModel : IConversationsListModel {
    weak var delegate: IConversationsListModelDelegate? 
    var communicationService: CommunicatorDelegate?
    var conversations: [ConversationsListCellData] = []
    
    init(communicationService: CommunicatorDelegate) {
        self.communicationService = communicationService
        self.communicationService?.delegate = self
    }
    
    func getConversations() -> [ConversationsListCellData] {
        if let manager = communicationService {
            return manager.conversations
        }
        return []
    }
}

extension ConversationsListModel : CommunicationManagerDelegate {
    func reloadData() {
        (self.delegate as? ConversationsListViewController)?.setup(dataSource: getConversations())
    }
    
    
}
