//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/8/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConversationViewController: EmitterViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var footerView: UIView!
    
    private var activeTextField : UITextField?
    private var titleLabel = UILabel()
    
    var userId: String? = nil
    var isOnline: Bool = false
    private var messages: [ConversationCellData] = []
    
    var model : IConversationModel?
    var dataProvider : IDataProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTable()
        configureTapGestureRecognizer()
        configureMessafeField()
        
        configureSendButton()
        enableSendButton(enable: false)
        
        setTitle()
        
        guard let storage = model?.storageService, let context = storage.stack.saveContext else { return }
        let conversation = Conversation.findOrInsertConversation(userId: userId ?? "", name: "", in: context)
        dataProvider = ConversationDataProvider(tableView: tableView, conversationId: conversation?.conversationId ?? "", storage: storage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotifications(selectorShow: #selector(keyboardWillShow), selectorHide: #selector(keyboardWillHide))
        model?.userId = userId
        
        dataProvider?.fetchResults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateConversationTitle(isOnline: isOnline)
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
            } else if isOnline {
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
    
    private func configureSendButton() {
        sendMessageButton.layer.masksToBounds = true;
        sendMessageButton.layer.cornerRadius = 10;
        sendMessageButton.setTitleColor(UIColor .white, for: .normal)
        sendMessageButton.backgroundColor = UIColor.init(red: 90/255, green: 0/255, blue: 202/255, alpha: 1.0)
        sendMessageButton.contentEdgeInsets = UIEdgeInsetsMake(5.0, 8.0, 5.0, 8.0)
    }
    
    private func prepareConversationsListVC() {
        let conversationsListVC = ConversationsListAssembly().conversationsListViewCotnroller()
        self.navigationController?.setViewControllers([conversationsListVC.topViewController!], animated: false)
    }
    
    private func setTitle() {
        titleLabel.backgroundColor = UIColor .clear
        titleLabel.textAlignment = .center
        titleLabel.text = self.title
        self.navigationItem.titleView = titleLabel
        animateConversationTitle(isOnline: isOnline)
    }
    
    private func animateSendButton(enable: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.sendMessageButton.backgroundColor = enable ? UIColor.init(red: 90/255, green: 0/255, blue: 202/255, alpha: 1.0) : UIColor .lightGray
            self.sendMessageButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.sendMessageButton.transform = CGAffineTransform.identity
            })
        })

    }
    
    private func animateConversationTitle(isOnline: Bool) {
        
        UIView.transition(with: titleLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.titleLabel.font = isOnline ? UIFont .systemFont(ofSize: 19, weight: .bold) : UIFont .systemFont(ofSize: 17, weight: .bold)
            self.titleLabel.textColor = isOnline ? UIColor .green : UIColor .black
        }, completion: { _ in
            
        })
    }

}

// MARK: - Delegates

extension ConversationViewController: ICommunicationManagerDelegate, IHavingDependentOnStatusElements {
    func setOnlineStatus(isOnline: Bool) {
        guard messageField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false else { return }
        self.isOnline = isOnline
        enableSendButton(enable: isOnline)
        setTitle(isOnline: isOnline)
    }
    
    
    @objc func reloadData() {
        self.dataProvider?.fetchResults()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func enableSendButton(enable: Bool) {
        if (sendMessageButton.isEnabled != enable) {
            guard messageField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false else {
                DispatchQueue.main.async {
                    self.sendMessageButton.isEnabled = false
                    self.animateSendButton(enable: false)
                }
                return
            }
            DispatchQueue.main.async {
                self.sendMessageButton.isEnabled = enable
                self.animateSendButton(enable: enable)
            }
        }
    }
    
    func setTitle(isOnline: Bool) {
        self.animateConversationTitle(isOnline: isOnline)
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
