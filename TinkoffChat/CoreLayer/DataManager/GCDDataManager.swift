//
//  GCDDataManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

class GCDDataManager : IDataManager {
    
    func saveDictData(dictData: [String: String], toUrl: URL?, success: @escaping () -> (), failure: @escaping () -> ()) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            guard let url = toUrl else { return }
            if JSONSerialization.isValidJSONObject(dictData) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted) as NSData
                    try jsonData.write(to: url, options: .atomic)
                    DispatchQueue.main.async {
                        success()
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        failure()
                    }
                }
            }
        }
    }
    
    func loadDictData(setLoadedDictData: @escaping ([String: String]) -> (), fromUrl: URL?) {
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            guard let url = fromUrl else { return }
            do {
                guard let data = NSData(contentsOf: url) else { return }
                let jsonData = try JSONSerialization.jsonObject(with: data as Data, options: [])
                if let dictData = jsonData as? [String: String] {
                    DispatchQueue.main.async {
                        setLoadedDictData(dictData)
                    }
                } else {
                    print("JSON is invalid")
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
