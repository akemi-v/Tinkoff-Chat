//
//  PicUrlsParser.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit

struct PicUrlModel {
    let previewUrl : String
    let webformatUrl : String
}

class PicUrlsParser : Parser<[PicUrlModel]> {
    
    override func parse(data: Data) -> [PicUrlModel]? {
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                return nil
            }
            
            guard let hits = json["hits"] as? [[String: AnyObject]] else {
                return nil
            }
            
            var picUrlModels: [PicUrlModel] = []
            
            for hit in hits {
                guard let previewUrl = hit["previewURL"] as? String,
                    let webformatUrl = hit["webformatURL"] as? String else { continue }
                
                picUrlModels.append(PicUrlModel(previewUrl: previewUrl, webformatUrl: webformatUrl))
            }
            
            return picUrlModels
            
        } catch  {
            print("error trying to convert data to JSON")
            return nil
        }
    }
    
}
