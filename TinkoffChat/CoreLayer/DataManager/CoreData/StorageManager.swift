//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/3/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit
import CoreData

class StorageManager: NSObject, IDataManager {

    private var stack : ICoreDataStack = CoreDataStack()
    
    func saveDictData(dictData: [String : String], toUrl: URL?, completionHandler: @escaping (Bool) -> ()) {
                guard let context = stack.saveContext else { return }
        
                guard let appUser = AppUser.findOrInsertAppUser(in: context) else { return }
                appUser.name = dictData["name"]
                appUser.about = dictData["about"]
                appUser.pic = dictData["pic"]
        
                stack.performSave(context: context, completionHandler: completionHandler)
    }
    
    func loadDictData(setLoadedDictData: @escaping ([String : String]) -> (), fromUrl: URL?) {
        guard let context = stack.mainContext else { return }
        
        var dictData : [String: String] = [:]
        
        guard let appUser = AppUser.findOrInsertAppUser(in: context) else { return }
        dictData["name"] = appUser.name
        dictData["about"] = appUser.about
        dictData["pic"] = appUser.pic
        
        DispatchQueue.main.async {
            setLoadedDictData(dictData)
        }
    }
    
}
