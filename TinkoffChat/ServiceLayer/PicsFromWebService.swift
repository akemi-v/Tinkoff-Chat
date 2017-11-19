//
//  PicFromWebService.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IPicsFromWebService : class {
    func loadPicUrls(completionHandler: @escaping ([PicUrlModel]?, String?) -> Void)
    func loadPictureFromUrl(url: String, completionHandler: @escaping (PicModel?, String?) -> Void)
}

class PicsFromWebService : IPicsFromWebService {
    
    let requestSender : IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func loadPicUrls(completionHandler: @escaping ([PicUrlModel]?, String?) -> Void) {
        
        let requestConfig: RequestConfig<[PicUrlModel]> = RequestsFactory.PixabayRequests.picUrlsConfig()
        
        requestSender.send(config: requestConfig) { (result: Result<[PicUrlModel]>) in
            switch result {
            case .Success(let pics):
                completionHandler(pics, nil)
            case .Fail(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func loadPictureFromUrl(url: String, completionHandler: @escaping (PicModel?, String?) -> Void) {
        guard let url = URL(string: url) else {
            completionHandler(nil, "Cannot create URL from string")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let requestConfig: RequestConfig<PicModel> = RequestsFactory.PictureRequests.picConfig(urlRequest: urlRequest)
        
        requestSender.send(config: requestConfig) { (result: Result<PicModel>) in
            switch result {
            case .Success(let pic):
                completionHandler(pic, nil)
            case .Fail(let error):
                completionHandler(nil, error)
            }
        }
    }
    
}
