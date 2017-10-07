//
//  ConversationsListCell.swift
//  TinkoffChat
//
//  Created by Apple on 10/5/17.
//  Copyright © 2017 Mari. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration : class {
    var name : String? {get set}
    var message : String? {get set}
    var date : Date? {get set}
    var online : Bool {get set}
    var hasUnreadMessages : Bool {get set}
}

class ConversationsListCell: UITableViewCell, ConversationCellConfiguration {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    private var _name : String? = nil
    private var _message : String? = nil
    private var _date : Date? = nil
    private var _online : Bool = false
    private var _hasUnreadMessages : Bool = false
    
    var name: String? {
        get {
            return _name
        }
        set {
            _name = newValue
            self.nameLabel.text = _name
        }
    }
    
    var message: String? {
        get {
            return _message
        }
        set {
            if (newValue != nil) {
                _message = newValue
            } else {
                _message = "No messages yet"
                self.lastMessageLabel.font = UIFont.italicSystemFont(ofSize: 17.0)
            }
            self.lastMessageLabel.text = _message
        }
    }
    
    var date: Date? {
        get {
            return _date
        }
        set {
            _date = newValue
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let stringDate : String = formatter.string(from: _date!)

            self.timeLabel.text = stringDate
        }
    }
    
    var online: Bool {
        get {
            return _online
        }
        set {
            _online = newValue
        }
    }
    
    var hasUnreadMessages: Bool {
        get {
            return _hasUnreadMessages
        }
        set {
            _hasUnreadMessages = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
