//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/3/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit
import CoreData

class StorageManager: NSObject, IDataManager, IStorageManager {

    var stack: ICoreDataStack
    
    init(stack: ICoreDataStack) {
        self.stack = stack
    }
    
    func saveDictData(dictData: [String : String], toUrl: URL?, completionHandler: @escaping (Bool) -> ()) {
        guard let context = stack.saveContext else { return }
        
                guard let appUser = AppUser.findOrInsertAppUser(in: context) else { return }
                appUser.currentUser?.name = dictData["name"]
                appUser.currentUser?.about = dictData["about"]
                appUser.currentUser?.pic = dictData["pic"]
        
        stack.performSave(context: context, completionHandler: completionHandler)
    }
    
    func loadDictData(setLoadedDictData: @escaping ([String : String]) -> (), fromUrl: URL?) {
        guard let context = stack.mainContext else { return }
        
        var dictData : [String: String] = [:]
        
        guard let appUser = AppUser.findOrInsertAppUser(in: context) else { return }
        dictData["name"] = appUser.currentUser?.name
        dictData["about"] = appUser.currentUser?.about
        dictData["pic"] = appUser.currentUser?.pic
        
        DispatchQueue.main.async {
            setLoadedDictData(dictData)
        }
    }
    
    func setOnlineConversation(userID: String, userName: String?) {
        guard let context = stack.saveContext else { return }
        
        guard let user = User.findOrInsertUser(userId: userID, name: userName ?? "No name", in: context) else { return }
        user.name = userName
        user.isOnline = true
        
        guard let conversation = Conversation.findOrInsertConversation(userId: userID, name: userName ?? "No name", in: context) else { return }
        conversation.participant = user
        conversation.name = userName
        conversation.isOnline = user.isOnline
        conversation.date = conversation.lastMessage?.date
        
        user.conversations = conversation
        
        stack.performSave(context: context, completionHandler: nil)
    }
    
    func setOfflineConversation(userID: String) {
        guard let context = stack.saveContext else { return }
        
        guard let user = User.findOrInsertUser(userId: userID, name: "", in: context) else { return }
        user.isOnline = false
        
        guard let conversation = Conversation.findOrInsertConversation(userId: userID, name: "", in: context) else { return }
        conversation.isOnline = user.isOnline
        
        user.conversations = conversation
        
        stack.performSave(context: context, completionHandler: nil)
    }
    
    func setAllConversationsOffline() {
        guard let context = stack.saveContext else { return }
        let conversations = Conversation.findAllConversations(in: context)
        for conversation in conversations {
            conversation.isOnline = false
        }
        
        stack.performSave(context: context, completionHandler: nil)
    }
    
    func getAppUserName() -> String {
        guard let context = stack.saveContext else { return ""}
        
        return AppUser.getAppUserName(in: context) ?? "No name"
    }
    
    func setAppUserOffline() {
        guard let context = stack.saveContext else { return }
        let appUser = AppUser.findOrInsertAppUser(in: context)
        appUser?.currentUser?.isOnline = false
        
        stack.performSave(context: context, completionHandler: nil)
    }    
}
