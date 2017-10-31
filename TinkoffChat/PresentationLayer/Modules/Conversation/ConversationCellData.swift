//
//  ConversationCellData.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/8/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

struct ConversationCellData {
    var identifier : String?
    var textMessage : String?
    
    init(identifier : String?, textMessage : String?) {
        self.identifier = identifier
        self.textMessage = textMessage
    }
}
