//
//  PicsFromWebRequest.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

class PixabayPicUrlsRequest : IRequest {
    
    private var baseUrl: String = "https://pixabay.com/api/?key="
    private var apiKey: String = "7094402-7641455c8b20aa2c64d2b41d6"
    private var searchTerm: String = "&q=robin"
    private var numberOfPics: String = "&per_page=200"
    
    var urlRequest: URLRequest? {
        let urlString: String = baseUrl + apiKey + searchTerm + numberOfPics
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        
        return nil
    }

}
