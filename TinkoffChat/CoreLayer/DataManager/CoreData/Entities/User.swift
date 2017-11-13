//
//  User.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/3/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension User {
    static func fetchRequestUser(userId: String, model: NSManagedObjectModel) -> NSFetchRequest<User>? {
        let templateName = "UserWithId"
        guard let fetchRequest = model.fetchRequestFromTemplate(withName: templateName, substitutionVariables: ["USERID": userId]) as? NSFetchRequest<User> else {
            assert(false, "No template with name \(templateName)")
            return nil
        }
        
        return fetchRequest
    }

    static func findOrInsertUser(userId: String, name: String, in context: NSManagedObjectContext) -> User? {
        
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var user : User?
        
        guard let fetchRequest = User.fetchRequestUser(userId: userId, model: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple Users with the same id found!")
            if let foundUser = results.first {
                user = foundUser
            }
        } catch {
            print("Failed to fetch User: \(error)")
        }
        
        if user == nil {
            user = User.insertUser(userId: userId, in: context)
            user?.name = name
        }
        
        return user
    }
    
    static func insertUser(userId: String, in context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            user.userId = userId
            
            return user
        }
        
        return nil
    }
    
    static func generateUserIdString() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
    
    static func generateCurrentUserNameString() -> String {
        return "Current User Name"
    }

}
