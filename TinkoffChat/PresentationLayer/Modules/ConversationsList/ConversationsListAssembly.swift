//
//  ConversationsListAssembly.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit

class ConversationsListAssembly {
    func conversationsListViewCotnroller() -> UINavigationController {
        let model = conversationsListModel()
        let storyboard = UIStoryboard(name: "ConversationsList", bundle: nil)
        if let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController, let conversationsListVC = navigationController.viewControllers.first as? ConversationsListViewController {
            conversationsListVC.model = model
            model.delegate = conversationsListVC
            return navigationController
        }
        return UINavigationController()
    }
    
    // MARK: - PRIVATE SECTION
    
    private func conversationsListModel() -> IConversationsListModel {
        return ConversationsListModel(communicationService: communicationManager())
    }
    
    private func communicationManager() -> ICommunicatorDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.rootAssembly.communicationManager
    }

}
