//
//  PictureParser.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/19/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit

struct PicModel {
    let image : UIImage
}

class PictureParser : Parser<PicModel> {
    
    override func parse(data: Data) -> PicModel? {
        
        guard let image = UIImage(data: data) else {
            print("error trying to convert data to UIImage")
            return nil
        }
        
        return PicModel(image: image)
    }
    
}
