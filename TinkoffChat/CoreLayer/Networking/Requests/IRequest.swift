//
//  IRequest.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 11/18/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

protocol IRequest : class {
    var urlRequest: URLRequest? { get }
}
