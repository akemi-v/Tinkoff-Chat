//
//  Helpers.swift
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

extension UIViewController {
    func registerForKeyboardNotifications(selectorShow: Selector, selectorHide: Selector) {
        NotificationCenter.default.addObserver(self, selector: selectorShow, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: selectorHide, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}
