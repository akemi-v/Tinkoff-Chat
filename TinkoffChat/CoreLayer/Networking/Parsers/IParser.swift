//
//  IParser.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IParser : class {
    associatedtype Model
    func parse(data: Data) -> Model?
}
