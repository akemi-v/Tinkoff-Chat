//
//  IDataManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IDataManager {
    
    func saveDictData(dictData: [String: String], toUrl: URL?, success: @escaping () -> (), failure: @escaping () -> ())
    func loadDictData(setLoadedDictData: @escaping ([String: String]) -> (), fromUrl: URL?)
}
