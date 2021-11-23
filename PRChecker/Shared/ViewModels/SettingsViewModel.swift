//
//  SettingsViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import Foundation

enum RefreshSetting: TimeInterval, CaseIterable {
    case fiveMinutes = 300
    case tenMinutes = 600
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    case oneHour = 3600
    case never = -1
}

struct DisplayOption: OptionSet {
    let rawValue: Int
    
    static let assigned = DisplayOption(rawValue: 1 << 0)
    static let reviewRequested = DisplayOption(rawValue: 1 << 1)
    static let reviewed = DisplayOption(rawValue: 1 << 2)
}

class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    
    @Published var userList: [String] {
        didSet {
            UserDefaults.standard.userList = userList
        }
    }
    @Published var refreshInterval: RefreshSetting {
        didSet {
            UserDefaults.standard.refreshInterval = refreshInterval
        }
    }
    @Published var displayOptions: DisplayOption {
        didSet {
            UserDefaults.standard.displayOptions = displayOptions
        }
    }
    
    @Published var loginViewModel = LoginInfoViewModel()
        
    private init() {
        if let existingUserList = UserDefaults.standard.userList {
            userList = existingUserList
        } else {
            userList = []
        }
        
        refreshInterval = UserDefaults.standard.refreshInterval
        displayOptions = UserDefaults.standard.displayOptions
    }
    
    func addUser(_ username: String) {
        guard !username.isEmpty else { return }
        userList = ([username.lowercased()] + userList).arrayByRemovingDuplicates().sorted(by: <)
    }
    
    func remove(_ username: String) {
        userList.removeAll { name in
            name.lowercased() == username.lowercased()
        }
    }
    
    func remove(_ indexSet: IndexSet) {
        userList.remove(atOffsets: indexSet)
    }
}
