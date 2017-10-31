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
    
    func saveProfileDataGCD(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ())
    func saveProfileDataOperation(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ())
    func loadProfileDataGCD(setLoadedData: @escaping ([String: String]) -> ())
    func loadProfileDataOperation(setLoadedData: @escaping ([String: String]) -> ())
}

class ProfileModel : IProfileModel {
    private var profileService: IProfileService
    
    init(profileService: IProfileService) {
        self.profileService = profileService
    }
    
    func saveProfileDataGCD(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
        profileService.saveDataGCD(profileData: profileData, success: success, failure: failure)
    }
    
    func saveProfileDataOperation(profileData: [String: String], success: @escaping () -> (), failure: @escaping () -> ()) {
        profileService.saveDataOperation(profileData: profileData, success: success, failure: failure)
    }
    
    func loadProfileDataGCD(setLoadedData: @escaping ([String: String]) -> ()) {
        profileService.loadDataGCD(setLoadedData: setLoadedData)
    }
    
    func loadProfileDataOperation(setLoadedData: @escaping ([String: String]) -> ()) {
        profileService.loadDataOperation(setLoadedData: setLoadedData)
    }

}
