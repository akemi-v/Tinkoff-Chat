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
    var communicationService : CommunicatorDelegate { get set }
}

protocol IConversationModelDelegate : class {
    func setup(dataSource: [ConversationCellData])
}

class ConversationModel : IConversationModel {
    weak var delegate: IConversationModelDelegate?
    var communicationService: CommunicatorDelegate
    
    init(communicationService: CommunicatorDelegate) {
        self.communicationService = communicationService
    }
}
