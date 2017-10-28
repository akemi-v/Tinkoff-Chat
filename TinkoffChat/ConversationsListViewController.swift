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
    
    let communicator = MultipeerCommunicator.shared
    let manager = CommunicationManager.shared
    
    let sectionsHeaders = ["Online", "History"]
        
    var conversations : [ConversationsListCellData] = []
    var conversationMessages : [String: [ConversationCellData]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.estimatedRowHeight = 144
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        manager.conversationsListVC = self

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        self.conversations.removeAll()
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let cell : ConversationsListCell = sender as? ConversationsListCell else { return }
        guard let destinationVC = segue.destination as? ConversationViewController else { return }
        
        cell.hasUnreadMessages  = false
        
        destinationVC.title = cell.name
        destinationVC.userId = cell.ID
        
        guard let cellID = cell.ID else { return }
        
        if conversationMessages[cellID] == nil {
            conversationMessages[cellID] = []
            cell.lastIncoming = false
        }
    }
}
