//
//  IStorageManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/13/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IStorageManager {
    
    var stack : ICoreDataStack { get }
    func getAppUserName() -> String
    func setAppUserOffline()
    func setOnlineConversation(userID: String, userName: String?)
    func setOfflineConversation(userID: String)
    func setAllConversationsOffline()
}
