//
//  ConversationsListCell.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/5/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
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
            _message = newValue
            if _message != nil {
                self.lastMessageLabel.text = _message
                self.lastMessageLabel.textColor = UIColor .black
                self.lastMessageLabel.font = UIFont.systemFont(ofSize: 17.0)
            } else {
                self.lastMessageLabel.text = "No messages yet"
                self.lastMessageLabel.textColor = UIColor .gray
                self.lastMessageLabel.font = UIFont.italicSystemFont(ofSize: 17.0)
            }
        }
    }
    
    var date: Date? {
        get {
            return _date
        }
        set {
            _date = newValue
            if let trueDate = _date {
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(trueDate) {
                    dateFormatter.dateFormat = "HH:mm"
                } else {
                    dateFormatter.dateFormat = "dd MMM"
                }
                let stringDate : String = dateFormatter.string(from: trueDate)
                
                self.timeLabel.text = stringDate
            } else {
                return
            }
        }
    }
    
    var online: Bool {
        get {
            return _online
        }
        set {
            _online = newValue
            if _online {
                self.backgroundColor = UIColor(red: 252/255, green: 243/255, blue: 197/255, alpha: 1.0)
            } else {
                self.backgroundColor = UIColor .white
            }
        }
    }
    
    var hasUnreadMessages: Bool {
        get {
            return _hasUnreadMessages
        }
        set {
            _hasUnreadMessages = newValue
            if _hasUnreadMessages {
                self.lastMessageLabel.font = UIFont.boldSystemFont(ofSize: 19.0)
            } else if _message != nil {
                self.lastMessageLabel.font = UIFont.systemFont(ofSize: 17.0)
            } else {
                self.lastMessageLabel.font = UIFont.italicSystemFont(ofSize: 17.0)
            }
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
