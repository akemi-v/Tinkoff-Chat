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
    func conversationViewCotnroller() -> ConversationViewController {
        let model = conversationModel()
        let storyboard = UIStoryboard(name: "Conversation", bundle: nil)
        let conversationVC = storyboard.instantiateInitialViewController() as! ConversationViewController
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
