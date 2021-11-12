//
//  SettingsViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import Foundation

struct SettingsViewModel {
    var userList: [String]
    
    var newUsername: String = ""
    
    init() {
        if let existingUserList = UserDefaults.standard.userList {
            userList = existingUserList
        } else {
            userList = []
        }
    }
    
    mutating func addUser() {
        guard !newUsername.isEmpty else { return }
        userList = ([newUsername.lowercased()] + userList).arrayByRemovingDuplicates().sorted(by: <)
        newUsername = ""
        UserDefaults.standard.userList = userList
    }
    
    mutating func remove(_ username: String) {
        userList.removeAll { name in
            name.lowercased() == username.lowercased()
        }
        UserDefaults.standard.userList = userList
    }
}
