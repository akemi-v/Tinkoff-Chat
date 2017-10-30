//
//  ProfileService.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IProfileService {
    func saveDataGCD(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ())
    func saveDataOperation(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ())
    func loadDataGCD(setLoadedData: @escaping ([String: String]) -> ())
    func loadDataOperation(setLoadedData: @escaping ([String: String]) -> ())
}

class ProfileService : IProfileService {
    
    var dataManager : IDataManager?
    
    let url : URL

    init() {
        let fileName = "profile.json"
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        self.url = URL(fileURLWithPath: documents).appendingPathComponent(fileName)
//        self.dataManager = dataManager
    }
    
    func saveDataGCD(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
        dataManager = GCDDataManager()
        dataManager?.saveDictData(dictData: profileData, toUrl: self.url, success: success, failure: failure)
    }
    
    func saveDataOperation(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
        dataManager = OperationDataManager()
        dataManager?.saveDictData(dictData: profileData, toUrl: self.url, success: success, failure: failure)
    }
    
    func loadDataGCD(setLoadedData: @escaping ([String: String]) -> ()) {
        dataManager = GCDDataManager()
        dataManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: self.url)
    }
    
    func loadDataOperation(setLoadedData: @escaping ([String: String]) -> ()) {
        dataManager = OperationDataManager()
        dataManager?.loadDictData(setLoadedDictData: setLoadedData, fromUrl: self.url)
    }
}
