//
//  ProfilePicFromWebAssembly.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit

class ProfilePicFromWebAssembly {
    func profilePicFromWebViewController(completionHandler: @escaping (UIImage?) -> Void) -> UINavigationController? {
        let model = picFromWebModel()
        let storyboard = UIStoryboard(name: "ProfilePicFromWeb", bundle: nil)
        if let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController,
            let profilePicFromWebVC = navigationController.viewControllers.first as? ProfilePicFromWebViewController {
            profilePicFromWebVC.model = model
            profilePicFromWebVC.setProfilePic = completionHandler
            
            return navigationController
        }
        return nil
    }
    
    // MARK: - PRIVATE SECTION
    
    private func picFromWebModel() -> IPicFromWebModel {
        return PicFromWebModel(picsService: picsFromWebService())
    }
    
    private func picsFromWebService() -> IPicsFromWebService {
        return PicsFromWebService(requestSender: requestSender())
    }
    
    private func requestSender() -> IRequestSender {
        return RequestSender()
    }
}

