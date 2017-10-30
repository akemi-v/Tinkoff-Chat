//
//  MessageCell.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/8/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration : class {
    var textMessage : String? {get set}
}

class MessageCell: UITableViewCell, MessageCellConfiguration {
    
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    private var _textMessage : String? = nil
    
    var textMessage: String? {
        
        get {
            return _textMessage
        }
        set {
            _textMessage = newValue
            self.textMessageLabel.text = _textMessage
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.messageView.layer.masksToBounds = true
        self.messageView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
