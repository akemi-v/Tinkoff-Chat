//
//  OperationDataManager.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

class OperationDataManager : IDataManager {
    func saveDictData(dictData: [String : String], toUrl: URL?, completionHandler: @escaping (Bool) -> ()) {
        let queue = OperationQueue()
        
        guard let url = toUrl else { return }
        let saveOperation : AsyncOperation = AsyncOperation(dictData: dictData, saveData: true, url: url, completionHandler: completionHandler)
        queue.addOperation(saveOperation)
    }
    
    
//    func saveDictData(dictData: [String: String], toUrl: URL?, success: @escaping () -> (), failure: @escaping () -> ()) {
//        let queue = OperationQueue()
//        
//        guard let url = toUrl else { return }
//        let saveOperation : AsyncOperation = AsyncOperation(dictData: dictData, saveData: true, url: url, success: success, failure: failure)
//        queue.addOperation(saveOperation)
//    }
    
    func loadDictData(setLoadedDictData: @escaping ([String: String]) -> (), fromUrl: URL?) {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        
        guard let url = fromUrl else { return }
        let loadOperation : AsyncOperation = AsyncOperation(saveData: false, url: url, setLoadedDictData: setLoadedDictData)
        queue.addOperation(loadOperation)
    }
}

class AsyncOperation : Operation {
    private var _dictData : [String: String]? = nil
//    private var _success : (() -> ())? = nil
//    private var _failure : (() -> ())? = nil
    private var _completionHandler : ((Bool) -> ())? = nil
    private var _setLoadedDictData: (([String: String]) -> ())? = nil
    private var _saveData : Bool = false
    private var _url: URL
    
    init(dictData: [String: String], saveData: Bool, url: URL, completionHandler: @escaping (Bool) -> ()) {
        self._dictData = dictData
        self._saveData = saveData
        self._url = url
//        self._success = success
//        self._failure = failure
        self._completionHandler = completionHandler
        
    }
    
    init(saveData: Bool, url: URL, setLoadedDictData: @escaping ([String: String]) -> ()) {
        self._saveData = saveData
        self._url = url
        self._setLoadedDictData = setLoadedDictData
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }
    
    override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .executing
            
            if self._saveData {
                do {
                    let jsonData: NSData
                    
                    if JSONSerialization.isValidJSONObject(self._dictData as Any) {
                        do {
                            jsonData = try JSONSerialization.data(withJSONObject: self._dictData as Any, options: .prettyPrinted) as NSData
                            try jsonData.write(to: self._url, options: .atomic)
                            OperationQueue.main.addOperation {
                                self._completionHandler?(true)
                            }
                        } catch {
                            print(error)
                            self._completionHandler?(false)
                        }
                    }
                }
            } else {
                do {
                    guard let data = NSData(contentsOf: self._url) else { return }
                    let json = try JSONSerialization.jsonObject(with: data as Data, options: [])
                    if let object = json as? [String: String] {
                        OperationQueue.main.addOperation {
                            self._setLoadedDictData?(object)
                        }
                    } else {
                        print("JSON is invalid")
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return
    }
}
