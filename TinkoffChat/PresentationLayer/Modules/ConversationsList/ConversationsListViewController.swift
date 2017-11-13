//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/5/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConversationsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var conversations : [ConversationsListCellData] = []
    
    var model : IConversationsListModel?
    var dataProvider : IDataProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTable()
        
        guard let storage = model?.storageService else { return }
        dataProvider = ConversationsListDataProvider(tableView: tableView, storage: storage) as? IDataProvider
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        dataProvider?.fetchResults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        dataProvider?.storage.setAppUserOffline()
//        setup(dataSource: [])
//        model?.clearConversations()
    }
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let frc = (self.dataProvider as? ConversationsListDataProvider)?.fetchedResultsController, let sectionsCount = frc.sections?.count else { return 0 }
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let frc = (self.dataProvider as? ConversationsListDataProvider)?.fetchedResultsController, let sections = frc.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Conversation Cell ID"
        var cell : ConversationsListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationsListCell {
            cell = dequeuedCell
        } else {
            cell = ConversationsListCell(style: .default, reuseIdentifier: identifier)
        }
        
        if let conversation = (self.dataProvider as? ConversationsListDataProvider)?.fetchedResultsController.object(at: indexPath) {
            cell.ID = conversation.conversationId
            cell.name = conversation.participant?.name
            cell.date = conversation.lastMessage?.date
            cell.message = conversation.lastMessage?.text
            if let count = conversation.unreadMessages?.count {
                cell.hasUnreadMessages = count > 0 ? true : false
            } else {
                cell.hasUnreadMessages = false
            }
            cell.lastIncoming = conversation.lastMessage?.incoming ?? false
            cell.online = conversation.isOnline
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let frc = (self.dataProvider as? ConversationsListDataProvider)?.fetchedResultsController,
                        let sections = frc.sections,
                        let object = sections[section].objects?.first as? Conversation else { return nil }
        
        let header = object.isOnline ? "Online" : "History"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let frcObject = (self.dataProvider as? ConversationsListDataProvider)?.fetchedResultsController.object(at: indexPath) else { return }
        prepareConversationVC(title: frcObject.participant?.name, userId: frcObject.conversationId)
        
//        conversations[indexPath.row].hasUnreadMessages  = false
//        prepareConversationVC(title: conversations[indexPath.row].name, userId: conversations[indexPath.row].ID)
    }
    
    // MARK: - IBActions
    
    @IBAction func pressProfileButton(_ sender: UIButton) {
        prepareProfileVC()
    }

    // MARK: - Private methods
    private func configureTable() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 144
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func prepareConversationVC(title: String?, userId: String?) {
        let destinationVC = ConversationAssembly().conversationViewController()
        destinationVC.model?.delegate = destinationVC
        destinationVC.title = title
        destinationVC.userId = userId
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    private func prepareProfileVC() {
        let profileVC = ProfileAssembly().profileViewCotnroller()
        self.present(profileVC, animated: true, completion: nil)
    }
}

// MARK: - Delegates

extension ConversationsListViewController: ICommunicationManagerDelegate {
    
    func reloadData() {
        self.dataProvider?.fetchResults()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ConversationsListViewController: IConversationsListModelDelegate {
    func setup(dataSource: [ConversationsListCellData]) {
//        conversations = dataSource
        self.dataProvider?.fetchResults()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
