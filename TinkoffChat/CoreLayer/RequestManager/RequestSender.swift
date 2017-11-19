//
//  RequestSender.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

class RequestSender : IRequestSender {
    
    let session = URLSession.shared
    
    func send<Model>(config: RequestConfig<Model>, completionHandler: @escaping (Result<Model>) -> Void) {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.Fail("URL string can't be parsed to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.Fail(error.localizedDescription))
                return
            }
            
            guard let data = data,
                let parsedModel: Model = config.parser.parse(data: data) else {
                    completionHandler(Result.Fail("Received data can't be parsed"))
                    return
            }
            
            completionHandler(Result.Success(parsedModel))
        }
        
        task.resume()
    }
}

