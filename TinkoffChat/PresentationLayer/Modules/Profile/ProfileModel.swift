//
//  ProfileModel.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/30/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import UIKit

protocol IProfileModel : class {
    
    func saveData(mode: String, profileData: [String: String], completionHandler: @escaping (Bool) -> ())
    func loadData(mode: String, setLoadedData: @escaping ([String: String]) -> ())
}

class ProfileModel : IProfileModel {
    
    private var profileService: IProfileService
    
    init(profileService: IProfileService) {
        self.profileService = profileService
    }
    
    func saveData(mode: String, profileData: [String : String], completionHandler: @escaping (Bool) -> ()) {
        profileService.saveData(mode: mode, profileData: profileData, completionHandler: completionHandler)
    }
    
    func loadData(mode: String, setLoadedData: @escaping ([String : String]) -> ()) {
        profileService.loadData(mode: mode, setLoadedData: setLoadedData)
    }
}
