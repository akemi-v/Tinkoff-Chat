//
//  ProfileAssembly.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit

class ProfileAssembly {
    func profileViewCotnroller() -> UINavigationController {
        let model = profileModel()
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController, let profileVC = navigationController.viewControllers.first as? ProfileViewController {
            profileVC.model = model
            return navigationController
        }
        return UINavigationController()
    }
    
    // MARK: - PRIVATE SECTION
    
    private func profileModel() -> IProfileModel {
        return ProfileModel(profileService: profileService())
    }
    
    private func profileService() -> IProfileService {
        return ProfileService(gcdDataManager: gcdDataManager(), operationDataManager: operationDataManager(), storageManager: storageManager())
    }
    
    private func storageManager() -> (IDataManager & IStorageManager) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.rootAssembly.storageManager
    }
    
    private func gcdDataManager() -> IDataManager {
        return GCDDataManager()
    }
    
    private func operationDataManager() -> IDataManager {
        return OperationDataManager()
    }
    
}
