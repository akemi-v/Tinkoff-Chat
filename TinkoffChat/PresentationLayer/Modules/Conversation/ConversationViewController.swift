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
    
    private var activeTextField : UITextField?
    
    var userId: String? = nil
    private var messages: [ConversationCellData] = []
    
    var model : IConversationModel?
    var dataProvider : IDataProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTable()
        configureTapGestureRecognizer()
        configureMessafeField()

        enableSendButton(enable: false)
        
        guard let storage = model?.storageService, let context = storage.stack.saveContext else { return }
        let conversation = Conversation.findOrInsertConversation(userId: userId ?? "", name: "", in: context)
        dataProvider = ConversationDataProvider(tableView: tableView, conversationId: conversation?.conversationId ?? "", storage: storage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotifications(selectorShow: #selector(keyboardWillShow), selectorHide: #selector(keyboardWillHide))
        model?.userId = userId
        
        dataProvider?.fetchResults()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterForKeyboardNotifications()
//        model?.markConversationAsRead()
        guard let unwrappedUserId = userId else { return }
        dataProvider?.storage.markConversationAsRead(userId: unwrappedUserId)
        prepareConversationsListVC()
        
        super.viewWillDisappear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let frc = (self.dataProvider as? ConversationDataProvider)?.fetchedResultsController, let sectionsCount = frc.sections?.count else { return 0 }
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let frc = (self.dataProvider as? ConversationDataProvider)?.fetchedResultsController, let sections = frc.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let message = messages[indexPath.row]
//        let identifier = message.identifier ?? "Incoming Message Cell ID"
        
        guard let message = (self.dataProvider as? ConversationDataProvider)?.fetchedResultsController.object(at: indexPath) else { return MessageCell() }
        let identifier = message.incoming ? "Incoming Message Cell ID" : "Outgoing Message Cell ID"
        
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
        
        if let text = message.text {
            cell.textMessageLabel.text = text
        }

        cell.transform = CGAffineTransform(rotationAngle: .pi)
        return cell
    }
        
    // MARK: – Actions
    
    @IBAction func pressSendButton(_ sender: UIButton) {
        guard messageField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false else { return }
        guard let userIdUnwrapped = userId else { return }
        
        model?.communicationService?.sendMessage(string: messageField.text ?? "", to: userIdUnwrapped, completionHandler: nil)
        
        self.messageField.text = ""
        enableSendButton(enable: false)
        self.dataProvider?.fetchResults()
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
    
    // MARK: - Private methods
    
    private func configureTable() {
        tableView.dataSource = self
        tableView.estimatedRowHeight = 144
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.transform = CGAffineTransform(rotationAngle: -.pi);
    }
    
    private func configureTapGestureRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    private func configureMessafeField() {
        messageField.autocapitalizationType = .sentences;
        messageField.addTarget(self, action: #selector(checkInput), for: .editingChanged)
    }
    
    private func prepareConversationsListVC() {
        let conversationsListVC = ConversationsListAssembly().conversationsListViewCotnroller()
        self.navigationController?.setViewControllers([conversationsListVC.topViewController!], animated: false)
    }

}

// MARK: - Delegates

extension ConversationViewController: ICommunicationManagerDelegate, IHavingSendButton {
    
    @objc func reloadData() {
        self.dataProvider?.fetchResults()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func enableSendButton(enable: Bool) {
        DispatchQueue.main.async {
            self.sendMessageButton.isEnabled = enable
        }
    }

}

extension ConversationViewController: IConversationModelDelegate {
    func setup(dataSource: [ConversationCellData]) {
//        messages = dataSource
        self.dataProvider?.fetchResults()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
