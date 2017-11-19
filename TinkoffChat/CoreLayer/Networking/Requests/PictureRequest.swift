//
//  PicRequest.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/19/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

class PictureRequest : IRequest {
    
    var urlRequest: URLRequest?
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
}
