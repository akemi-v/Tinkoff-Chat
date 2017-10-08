//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/8/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let dummyMessages : [dummyConversationCellData] = [
        dummyConversationCellData(identifier: "Incoming Message Cell ID", textMessage: "I"),
        dummyConversationCellData(identifier: "Incoming Message Cell ID", textMessage: "Lorem ipsum dolor sit amet, co"),
        dummyConversationCellData(identifier: "Outgoing Message Cell ID", textMessage: "O"),
        dummyConversationCellData(identifier: "Incoming Message Cell ID", textMessage: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec."),
        dummyConversationCellData(identifier: "Outgoing Message Cell ID", textMessage: "Cupcake ipsum dolor sit amet muffin "),
        dummyConversationCellData(identifier: "Outgoing Message Cell ID", textMessage: "Cupcake ipsum dolor sit amet muffin gingerbread sugar plum. Wafer chupa chups jelly fruitcake powder sweet roll chocolate cake sesame snaps. Cake icing cake dessert bonbon candy canes. Carrot cake bonbon topping croissant tiramisu. Cheesecake powder liquorice dragée jujubes. Bonbon dessert chocolate. Pie liquorice gummi bears chocolate bar croissant")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 144
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.separatorStyle = .none
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
        return self.dummyMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.dummyMessages[indexPath.row]
        let identifier = message.identifier ?? "Incoming Message Cell ID"
        var cell : MessageCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MessageCell? {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier) as! MessageCell
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
        cell.textMessage = message.textMessage
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
