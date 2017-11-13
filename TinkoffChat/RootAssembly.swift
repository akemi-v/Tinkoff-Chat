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
    
    var multipeerCommunicator : ICommunicator
    var communicationManager : ICommunicatorDelegate
    var storageManager : (IDataManager & IStorageManager)
    
    init() {
        let stack = CoreDataStack()
        storageManager = StorageManager(stack: stack)
        multipeerCommunicator = MultipeerCommunicator(name: storageManager.getAppUserName())
        communicationManager = CommunicationManager(communicator: multipeerCommunicator, storage: storageManager)
    }
}
