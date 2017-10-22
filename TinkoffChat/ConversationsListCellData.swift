//
//  DummyConversationCellData.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/8/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

struct ConversationsListCellData {
    var ID : String?
    var name : String?
    var message : String?
    var date : Date?
    var online : Bool
    var hasUnreadMessages : Bool
    var lastIncoming : Bool
    
    init(ID : String?, name : String?, message : String?, date : Date?, online : Bool, hasUnreadMessages : Bool, lastIncoming : Bool) {
        self.ID = ID
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
        self.lastIncoming = lastIncoming
    }
}
