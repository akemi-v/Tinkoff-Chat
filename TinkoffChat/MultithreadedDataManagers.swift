//
//  MultithreadedDataManagers.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/14/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol ProfileDataManagementProtocol {
    
    var url : URL? { get }
    
    func saveProfileData(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ())
    func loadProfileData(setLoadedData: @escaping ([String: String]) -> ())
}

// MARK: - GCD

class GCDDataManager : ProfileDataManagementProtocol {
    
    internal var url : URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    func saveProfileData(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            guard let url = self.url else { return }
            if JSONSerialization.isValidJSONObject(profileData) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: profileData, options: .prettyPrinted) as NSData
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
    
    func loadProfileData(setLoadedData: @escaping ([String: String]) -> ()) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            guard let url = self.url else { return }
            do {
                guard let data = NSData(contentsOf: url) else { return }
                let jsonData = try JSONSerialization.jsonObject(with: data as Data, options: [])
                if let profileData = jsonData as? [String: String] {
                    DispatchQueue.main.async {
                        setLoadedData(profileData)
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

// MARK: - Operation

class OperationDataManager : ProfileDataManagementProtocol {
    
    internal var url : URL?
    
    init(url: URL?) {
        self.url = url
    }
    
    func saveProfileData(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        
        guard let url = self.url else { return }
        let saveOperation : AsyncOperation = AsyncOperation(data: profileData, saveData: true, url: url, success: success, failure: failure)
        queue.addOperation(saveOperation)
    }
    
    func loadProfileData(setLoadedData: @escaping ([String: String]) -> ()) {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        
        guard let url = self.url else { return }
        let loadOperation : AsyncOperation = AsyncOperation(saveData: false, url: url, setLoadedData: setLoadedData)
        queue.addOperation(loadOperation)
    }
}

class AsyncOperation : Operation {
    private var _data : [String: String]? = nil
    private var _success : (() -> ())? = nil
    private var _failure : (() -> ())? = nil
    private var _setLoadedData: (([String: String]) -> ())? = nil
    private var _saveData : Bool = false
    private var _url: URL
    
    init(data: [String: String], saveData: Bool, url: URL, success: @escaping () -> (), failure: @escaping () -> ()) {
        self._data = data
        self._saveData = saveData
        self._url = url
        self._success = success
        self._failure = failure
    }
    
    init(saveData: Bool, url: URL, setLoadedData: @escaping ([String: String]) -> ()) {
        self._saveData = saveData
        self._url = url
        self._setLoadedData = setLoadedData
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
                    
                    if JSONSerialization.isValidJSONObject(self._data as Any) {
                        do {
                            jsonData = try JSONSerialization.data(withJSONObject: self._data as Any, options: .prettyPrinted) as NSData
                            try jsonData.write(to: self._url, options: .atomic)
                            OperationQueue.main.addOperation {
                                self._success?()
                            }
                        } catch {
                            print(error)
                            self._failure?()
                        }
                    }
                }
            } else {
                do {
                    guard let data = NSData(contentsOf: self._url) else { return }
                    let json = try JSONSerialization.jsonObject(with: data as Data, options: [])
                    if let object = json as? [String: String] {
                        OperationQueue.main.addOperation {
                            self._setLoadedData?(object)
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

