//
//  RequestsFactory.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

struct RequestsFactory {
    
    struct PixabayRequests {
        
        static func picUrlsConfig() -> RequestConfig<[PicUrlModel]> {
            return RequestConfig<[PicUrlModel]>(request: PixabayPicUrlsRequest(), parser: PicUrlsParser())
        }
    }
    
    struct PictureRequests {
        static func picConfig(urlRequest: URLRequest) -> RequestConfig<PicModel> {
            return RequestConfig<PicModel>(request: PictureRequest(urlRequest: urlRequest), parser: PictureParser())
        }
    }
    
}
