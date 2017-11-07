//
//  ProfileService.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IProfileService {
//    func saveDataGCD(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ())
//    func saveDataOperation(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ())
//    func loadDataGCD(setLoadedData: @escaping ([String: String]) -> ())
//    func loadDataOperation(setLoadedData: @escaping ([String: String]) -> ())
    
    func saveData(mode: String, profileData: [String: String], completionHandler: @escaping (Bool) -> ())
    func loadData(mode: String, setLoadedData: @escaping ([String: String]) -> ())
}

class ProfileService : IProfileService {
    
    var storageManager : IDataManager?
    var gcdDataManager : IDataManager?
    var operationDataManager : IDataManager?
    
    let url : URL

    init(gcdDataManager: IDataManager, operationDataManager: IDataManager, storageManager: IDataManager) {
        let fileName = "profile.json"
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        self.url = URL(fileURLWithPath: documents).appendingPathComponent(fileName)
        
        self.storageManager = storageManager
        self.gcdDataManager = gcdDataManager
        self.operationDataManager = operationDataManager
    }
    
    func saveData(mode: String, profileData: [String : String], completionHandler: @escaping (Bool) -> ()) {
        switch mode {
        case "GCD":
            gcdDataManager?.saveDictData(dictData: profileData, toUrl: self.url, completionHandler: completionHandler)
        case "Operation":
            operationDataManager?.saveDictData(dictData: profileData, toUrl: self.url, completionHandler: completionHandler)
        case "Storage":
            storageManager?.saveDictData(dictData: profileData, toUrl: nil, completionHandler: completionHandler)
        default:
            print("Saving data is not available")
        }
    }
    
    func loadData(mode: String, setLoadedData: @escaping ([String : String]) -> ()) {
        switch mode {
        case "GCD":
            gcdDataManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: self.url)
        case "Operation":
            operationDataManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: self.url)
        case "Storage":
            storageManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: nil)
        default:
            print("Loading data is not available")
        }

        storageManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: nil)
    }
    
    
//    func saveDataGCD(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
//        dataManager = GCDDataManager()
//        dataManager?.saveDictData(dictData: profileData, toUrl: self.url, success: success, failure: failure)
//    }
//
//    func saveDataOperation(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
//        dataManager = OperationDataManager()
//        dataManager?.saveDictData(dictData: profileData, toUrl: self.url, success: success, failure: failure)
//    }
//
//    func loadDataGCD(setLoadedData: @escaping ([String: String]) -> ()) {
//        dataManager = GCDDataManager()
//        dataManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: self.url)
//    }
//
//    func loadDataOperation(setLoadedData: @escaping ([String: String]) -> ()) {
//        dataManager = OperationDataManager()
//        dataManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: self.url)
//    }
}
