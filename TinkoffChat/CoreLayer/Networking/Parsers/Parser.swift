//
//  Parser.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

class Parser<T> : IParser {
    typealias Model = T
    func parse(data: Data) -> T? { return nil }
}
