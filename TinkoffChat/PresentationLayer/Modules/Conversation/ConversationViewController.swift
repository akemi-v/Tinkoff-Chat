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
    
//    var manager : CommunicationManager?
    
    var userId: String? = nil
    var messages: [ConversationCellData] = []
    
    var model : IConversationModel?
    
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
        messageField.addTarget(self, action: #selector(checkInput), for: .editingChanged)
        
        enableSendButton(enable: false)
        
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        model?.userId = userId
        setup(dataSource: model?.getMessages() ?? [])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        model?.communicationService?.conversations.enumerated().forEach({ (index, conversation) in
            if userId == conversation.ID {
                model?.communicationService?.conversations[index].hasUnreadMessages = false
            }
        })

        
        let conversationsListVC = ConversationsListAssembly().conversationsListViewCotnroller()
        
        self.navigationController?.setViewControllers([conversationsListVC.topViewController!], animated: false)
        
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
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
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
        }

        cell.transform = CGAffineTransform(rotationAngle: .pi)
        return cell
    }
        
    // MARK: – Actions
    
    @IBAction func pressSendButton(_ sender: UIButton) {
        guard messageField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false else { return }
        guard let userIdUnwrapped = userId else { return }
        messages.insert(ConversationCellData(identifier: "Outgoing Message Cell ID", textMessage: messageField.text), at: 0)
        
        model?.communicationService?.conversationMessages[userIdUnwrapped] = messages
        
        model?.communicationService?.sendMessage(string: messageField.text ?? "", to: userIdUnwrapped, completionHandler: nil)
        
        model?.communicationService?.conversations.enumerated().forEach({ (index, conversation) in
            if userId == conversation.ID {
                model?.communicationService?.conversations[index].hasUnreadMessages = false
                model?.communicationService?.conversations[index].message = messageField.text
                model?.communicationService?.conversations[index].date = Date()
                model?.communicationService?.conversations[index].lastIncoming = false
            }

        })
        
        if let sortedConversations = sortConversationsListByDateThenName(conversations: model?.communicationService?.conversations) {
            model?.communicationService?.conversations = sortedConversations
        }
        
        self.messageField.text = ""
        enableSendButton(enable: false)
//        reloadData()
        setup(dataSource: messages)
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
        self.scrollView.isScrollEnabled = false
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Message field
    
    @objc func checkInput(_ textField: UITextField) {
        if let text = textField.text {
            if text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                enableSendButton(enable: false)
            } else {
                enableSendButton(enable: true)
            }
        } else {
            enableSendButton(enable: false)
        }
    }
}

// MARK: - CommunicationManagerDelegate

extension ConversationViewController: CommunicationManagerDelegate {
    @objc func reloadData() {
        guard let unwrappedUserId = userId else { return }
        guard let conversationMessages = model?.communicationService?.conversationMessages[unwrappedUserId] else { return }
        messages = conversationMessages
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - CommunicationManagerConversationDelegate

extension ConversationViewController: CommunicationManagerConversationDelegate {
    func enableSendButton(enable: Bool) {
        DispatchQueue.main.async {
            self.sendMessageButton.isEnabled = enable
        }
    }
}

extension ConversationViewController: IConversationModelDelegate {
    func setup(dataSource: [ConversationCellData]) {
        messages = dataSource
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
