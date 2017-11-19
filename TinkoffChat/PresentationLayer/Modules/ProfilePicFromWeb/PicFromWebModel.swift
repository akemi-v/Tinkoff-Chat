//
//  PicFromWebModel.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IPicFromWebModel : class {
    func fetchPicUrls(vcCompletionHandler: @escaping ([PicUrlModel]?, String?) -> Void)
    func loadPicFromUrl(url: String, vcCompletionHandler: @escaping (PicModel?, String?) -> Void)
}

class PicFromWebModel : IPicFromWebModel {
    
    let picsService : IPicsFromWebService
    var picUrls : [PicUrlModel]?
    var pic: PicModel?
    
    init(picsService: IPicsFromWebService) {
        self.picsService = picsService
    }
    
    func fetchPicUrls(vcCompletionHandler: @escaping ([PicUrlModel]?, String?) -> Void) {
        
        let completionHandler : ([PicUrlModel]?, String?) -> Void = { [weak self] (fetchedPics, error) in
            if let fetchedPics = fetchedPics {
                self?.picUrls = fetchedPics
                vcCompletionHandler(self?.picUrls, nil)
            } else {
                print(error ?? "Error during fetching images")
                vcCompletionHandler(nil, error)
            }
        }
        
        picsService.loadPicUrls(completionHandler: completionHandler)
    }
    
    func loadPicFromUrl(url: String, vcCompletionHandler: @escaping (PicModel?, String?) -> Void) {
        
        let completionHandler : (PicModel?, String?) -> Void = { [weak self] (pic, error) in
            if let pic = pic {
                self?.pic = pic
                vcCompletionHandler(self?.pic, nil)
            } else {
                print(error ?? "Error during loading image")
                vcCompletionHandler(nil, error)
            }
        }
        
        picsService.loadPictureFromUrl(url: url, completionHandler: completionHandler)
    }
}
