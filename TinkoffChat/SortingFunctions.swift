//
//  SortingFunctions.swift
//  TinkoffChat
//
//  Created by Maria Semakova on 10/22/17.
//  Copyright © 2017 Maria Semakova. All rights reserved.
//

import Foundation

func sortConversationsListByDateThenName(conversations: [ConversationsListCellData]?) -> [ConversationsListCellData]? {
    if conversations != nil {
        let sortedConversations = conversations?.sorted(by: {
            if $0.date ?? Date(timeIntervalSince1970: 0) != $1.date ?? Date(timeIntervalSince1970: 0) {
                return $0.date ?? Date(timeIntervalSince1970: 0) > $1.date ?? Date(timeIntervalSince1970: 0)
            } else {
                return $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? ""
            }
        })
        return sortedConversations
    }
    return conversations
}
