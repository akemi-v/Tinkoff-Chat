//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/8/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConversationViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var footerView: UIView!
    
    var activeTextField : UITextField?
    
    let communicator = MultipeerCommunicator.shared
    let manager = CommunicationManager.shared
    
    var userId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 144
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none

        tableView.transform = CGAffineTransform(rotationAngle: -.pi);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        messageField.autocapitalizationType = .sentences;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableSendButton), name: NSNotification.Name(rawValue: "notificationInfoUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: NSNotification.Name(rawValue: "messagesUpdated"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationInfoUser"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "messagesUpdated"), object: nil)
        
        guard let parentVC = manager.conversationsListVC else { return }
        for (index, conversation) in parentVC.conversations.enumerated() {
            if userId == conversation.ID {
                parentVC.conversations[index].hasUnreadMessages = false
            }
        }
        
        super.viewWillDisappear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let userIdUnwrapped = userId else { return 0 }
        guard let messages = manager.conversationsListVC?.conversationMessages[userIdUnwrapped] else { return 0 }
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userIdUnwrapped = userId else { return MessageCell() }
        guard let message = manager.conversationsListVC?.conversationMessages[userIdUnwrapped]?[indexPath.row] else { return MessageCell() }
        let identifier = message.identifier ?? "Incoming Message Cell ID"
        var cell : MessageCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageCell {
            cell = dequeuedCell
        } else {
            cell = MessageCell(style: .default, reuseIdentifier: identifier)
        }
        
        switch identifier {
        case "Incoming Message Cell ID":
            cell.messageView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
            cell.textMessageLabel.textColor = UIColor .black
        case "Outgoing Message Cell ID":
            cell.messageView.backgroundColor = UIColor(red: 72/255, green: 43/255, blue: 199/255, alpha: 1.0)
            cell.textMessageLabel.textColor = UIColor .white
        default:
            cell.messageView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
            cell.textMessageLabel.textColor = UIColor .black
        }
        
        if let text = message.textMessage {
            cell.textMessageLabel.text = text
        } else {
            cell.isHidden = true
        }
        cell.transform = CGAffineTransform(rotationAngle: .pi)
        return cell
    }
        
    // MARK: – Actions
    
    @IBAction func pressSendButton(_ sender: UIButton) {
        guard let userIdUnwrapped = userId else { return }
        if var messages = manager.conversationsListVC?.conversationMessages[userIdUnwrapped] {
            messages.insert(ConversationCellData(identifier: "Outgoing Message Cell ID", textMessage: messageField.text), at: 0)
            manager.conversationsListVC?.conversationMessages[userIdUnwrapped] = messages
        }
        
        communicator.sendMessage(string: messageField.text ?? "", to: userIdUnwrapped, completionHandler: nil)
        guard let parentVC = manager.conversationsListVC else { return }
        for (index, conversation) in parentVC.conversations.enumerated() {
            if userId == conversation.ID {
                parentVC.conversations[index].hasUnreadMessages = false
                parentVC.conversations[index].message = messageField.text
                parentVC.conversations[index].date = Date()
                parentVC.conversations[index].lastIncoming = false
            }
        }
        
        if let sortedConversations = sortConversationsListByDateThenName(conversations: parentVC.conversations) {
            parentVC.conversations = sortedConversations
        }
        
        DispatchQueue.main.async {
            self.messageField.text = ""
            parentVC.tableView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Keyboard related
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        guard let info = notification.userInfo else { return }
        guard let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var viewFrame : CGRect = self.view.frame
        viewFrame.size.height -= keyboardSize.height
        if let activeTextField = self.activeTextField {
            if (!viewFrame.contains(activeTextField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeTextField = nil
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func enableSendButton(_ notification: Notification) {
        DispatchQueue.main.async {
            if let enable: Bool = notification.object as? Bool {
                self.sendMessageButton.isEnabled = enable
            }
        }
    }
    
    @objc func updateTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
