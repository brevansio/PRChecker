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
        if let existingUserList = UserDefaults.standard.array(forKey: UserDefaultsKey.userList) as? [String] {
            userList = existingUserList
        } else {
            userList = []
        }
    }
    
    mutating func addUser() {
        guard !newUsername.isEmpty else { return }
        userList = ([newUsername.lowercased()] + userList).removingLaterDuplicates().sorted(by: <)
        newUsername = ""
        UserDefaults.standard.set(userList, forKey: UserDefaultsKey.userList)
    }
    
    mutating func remove(_ username: String) {
        userList.removeAll { name in
            name.lowercased() == username.lowercased()
        }
        UserDefaults.standard.set(userList, forKey: UserDefaultsKey.userList)
    }
}
