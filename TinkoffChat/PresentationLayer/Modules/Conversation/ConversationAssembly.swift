//
//  ConversationAssembly.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit

class ConversationAssembly {
    func conversationViewController() -> ConversationViewController {
        let model = conversationModel()
        let storyboard = UIStoryboard(name: "Conversation", bundle: nil)
//        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
//        let conversationVC = navigationController.viewControllers.first as! ConversationViewController
        let conversationVC = storyboard.instantiateInitialViewController() as! ConversationViewController
        conversationVC.model = model
        model.delegate = conversationVC
        return conversationVC
    }
    
    // MARK: - PRIVATE SECTION
    
    private func conversationModel() -> IConversationModel {
        return ConversationModel(communicationService: communicationManager())
    }
    
    private func communicationManager() -> CommunicatorDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.rootAssembly.communicationManager
    }
    
}
