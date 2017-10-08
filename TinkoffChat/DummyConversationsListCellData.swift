//
//  DummyConversationCellData.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/8/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

struct dummyConversationsListCellData {
    var name : String?
    var message : String?
    var date : Date?
    var online : Bool
    var hasUnreadMessages : Bool
    
    init(name : String?, message : String?, date : Date?, online : Bool, hasUnreadMessages : Bool) {
        self.name = name
        self.message = message
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
}


func generateRandomStringWithLength(length : Int) -> String {
    var randomString : String = ""
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    for _ in 1...length {
        let randomIndex  = Int(arc4random_uniform(UInt32(letters.characters.count)))
        let a = letters.index(letters.startIndex, offsetBy: randomIndex)
        randomString +=  String(letters[a])
    }

    return randomString
}

func generateRandomDate() -> Date {
    let randomDate : Date = Calendar.current.date(byAdding: .minute, value: -Int(arc4random_uniform(1500)), to: Date()) ?? Date()
    
    return randomDate
}

func generateRandomBool() -> Bool {
    let randomBool : Bool = arc4random_uniform(2) == 0
    
    return randomBool
}
