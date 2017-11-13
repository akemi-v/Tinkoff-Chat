//
//  IDataProvider.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/12/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation
import CoreData

protocol IDataProvider : class {
    var storage : IStorageManager { get }
    func fetchResults()
}
