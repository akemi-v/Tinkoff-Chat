//
//  PicCollectionViewCell.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/19/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class PicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(image: UIImage?) {
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFit
    }
}
