//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/5/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let sectionsHeaders = ["Online", "History"]
    
    let numOfUsers : [String: Int] = ["Online": 10, "Offline": 10]
    
    var dummyConversations : [dummyConversationsListCellData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 144
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        dummyConversations.append(dummyConversationsListCellData(name: "Нерандом", message: nil, date: Date(), online: true, hasUnreadMessages: false))
        
        for _ in 1...numOfUsers["Online"]! - 1 {
            let dummyName = generateRandomStringWithLength(length: Int(arc4random_uniform(10) + 1))
            let dummyMessage = generateRandomStringWithLength(length: Int(arc4random_uniform(50) + 1))
            let dummyDate = generateRandomDate()
            let dummyOnline = true
            let dummyHasUnreadMessages = generateRandomBool()
            dummyConversations.append(dummyConversationsListCellData(name: dummyName, message: dummyMessage, date: dummyDate, online: dummyOnline, hasUnreadMessages: dummyHasUnreadMessages))
        }
        
        for _ in 0...numOfUsers["Offline"]! - 1 {
            let dummyName = generateRandomStringWithLength(length: Int(arc4random_uniform(10) + 1))
            let dummyMessage = generateRandomStringWithLength(length: Int(arc4random_uniform(50) + 1))
            let dummyDate = generateRandomDate()
            let dummyOnline = false
            let dummyHasUnreadMessages = generateRandomBool()
            dummyConversations.append(dummyConversationsListCellData(name: dummyName, message: dummyMessage, date: dummyDate, online: dummyOnline, hasUnreadMessages: dummyHasUnreadMessages))
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return numOfUsers["Online"]!
        } else {
            return numOfUsers["Offline"]!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Conversation Cell ID"
        var cell : ConversationsListCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! ConversationsListCell? {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier) as! ConversationsListCell
        }
        
        var conversation : dummyConversationsListCellData
        if indexPath.section == 0 {
            conversation = dummyConversations[indexPath.row]
        } else {
            conversation = dummyConversations[numOfUsers["Online"]! + indexPath.row]
        }

        cell.name = conversation.name
        cell.message = conversation.message
        cell.date = conversation.date
        cell.online = conversation.online
        cell.hasUnreadMessages = conversation.hasUnreadMessages
        
        
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
        
        guard let cell : ConversationsListCell = sender as? ConversationsListCell else {
            return
        }
        segue.destination.title = cell.name
    }
    
}
