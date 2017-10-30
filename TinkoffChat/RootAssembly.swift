//
//  RootAssembly.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

class RootAssembly {
    var conversationsListModule: ConversationsListAssembly = ConversationsListAssembly()
    
    var multipeerCommunicator : Communicator
    var communicationManager : CommunicatorDelegate
    
    init() {
        multipeerCommunicator = MultipeerCommunicator()
        communicationManager = CommunicationManager(communicator: multipeerCommunicator)
    }
//    private func communicationManager() -> CommunicatorDelegate {
//        return CommunicationManager(communicator: communicator())
//    }
//
//    private func communicator() -> Communicator {
//        return MultipeerCommunicator()
//    }
}
