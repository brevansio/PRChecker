//
//  SettingsViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import Foundation

struct SettingsViewModel {
    var userList: [String]
    var legacyMode: Bool = false
        
    init() {
        if let existingUserList = UserDefaults.standard.userList {
            userList = existingUserList
        } else {
            userList = []
        }
    }
    
    mutating func addUser(_ username: String) {
        guard !username.isEmpty else { return }
        userList = ([username.lowercased()] + userList).arrayByRemovingDuplicates().sorted(by: <)
        UserDefaults.standard.userList = userList
    }
    
    mutating func remove(_ username: String) {
        userList.removeAll { name in
            name.lowercased() == username.lowercased()
        }
        UserDefaults.standard.userList = userList
    }
    
    mutating func remove(_ indexSet: IndexSet) {
        userList.remove(atOffsets: indexSet)
        UserDefaults.standard.userList = userList
    }
}
