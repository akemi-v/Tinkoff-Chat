//
//  UITextViewFixed.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/15/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
