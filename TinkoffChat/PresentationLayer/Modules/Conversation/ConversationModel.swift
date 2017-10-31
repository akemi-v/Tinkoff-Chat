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
    var communicationService : CommunicatorDelegate? { get set }
    var userId : String? { get set }
    
    func getMessages() -> [ConversationCellData]
}

protocol IConversationModelDelegate : class {
    func setup(dataSource: [ConversationCellData])
}

class ConversationModel : IConversationModel {
    weak var delegate: IConversationModelDelegate?
    var communicationService: CommunicatorDelegate?
    var conversations: [ConversationCellData] = []
    var userId: String?
    
    init(communicationService: CommunicatorDelegate) {
        self.communicationService = communicationService
        self.communicationService?.delegate = self
    }
    
    func getMessages() -> [ConversationCellData] {
        guard let unwrappedUserId = userId else { return [] }
        if let manager = communicationService {
            return manager.conversationMessages[unwrappedUserId] ?? []
        }
        return []
    }
}

extension ConversationModel : CommunicationManagerDelegate {
    func reloadData() {
        (self.delegate as? ConversationViewController)?.setup(dataSource: getMessages())
    }
}
