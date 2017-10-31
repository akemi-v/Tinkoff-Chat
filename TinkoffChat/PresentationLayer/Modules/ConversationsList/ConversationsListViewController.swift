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
    
//    var manager = CommunicationManager(communicator: MultipeerCommunicator())
    
    let sectionsHeaders = ["Online", "History"]
        
    var conversations : [ConversationsListCellData] = []
    
    var model : IConversationsListModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.estimatedRowHeight = 144
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
//        manager.conversationsListDelegate = self
        
//        let getConversations : ([ConversationsListCellData]) -> () = { [weak self] data in
//            self?.conversations = data
//        }
//        model?.getConversations(getConversations: getConversations)
//        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        setup(dataSource: model?.getConversations() ?? [])

//        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
//        manager.conversations.removeAll()
        setup(dataSource: [])
        model?.communicationService?.conversations.removeAll()
//        conversations.removeAll()
//        reloadData()
    }
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.sectionsHeaders.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return conversations.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Conversation Cell ID"
        var cell : ConversationsListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationsListCell {
            cell = dequeuedCell
        } else {
            cell = ConversationsListCell(style: .default, reuseIdentifier: identifier)
        }
        
        cell.ID = conversations[indexPath.row].ID
        cell.name = conversations[indexPath.row].name
        cell.date = conversations[indexPath.row].date
        cell.message = conversations[indexPath.row].message
        cell.hasUnreadMessages = conversations[indexPath.row].hasUnreadMessages
        cell.lastIncoming = conversations[indexPath.row].lastIncoming
        cell.online = conversations[indexPath.row].online
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        conversations[indexPath.row].hasUnreadMessages  = false
        model?.communicationService?.conversations[indexPath.row].hasUnreadMessages = false
        let destinationVC = ConversationAssembly().conversationViewController()
        destinationVC.title = conversations[indexPath.row].name
        destinationVC.userId = conversations[indexPath.row].ID
//        destinationVC.model?.communicationService?.delegate = destinationVC
        destinationVC.model?.delegate = destinationVC
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    @IBAction func pressProfileButton(_ sender: UIButton) {
        let profileVC = ProfileAssembly().profileViewCotnroller()
        self.present(profileVC, animated: true, completion: nil)
    }

    
}

// MARK: - CommunicationManagerDelegate

extension ConversationsListViewController: CommunicationManagerDelegate {
    func reloadData() {
//        conversations = manager.conversations
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ConversationsListViewController: IConversationsListModelDelegate {
    func setup(dataSource: [ConversationsListCellData]) {
        conversations = dataSource
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
