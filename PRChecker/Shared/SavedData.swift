//
//  SavedData.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import Foundation

enum KeychainKey {
    static let service = "io.brevans.PRChecker"
    static let apiEndpoint = "API_ENDPOINT_URL"
    static let username = "USERNAME"
    static let accessToken = "ACCESST_TOKEN"
}

extension UserDefaults {
    private enum UserDefaultsKey {
        static let userList = "io.brevans.PRChecker.userList"
        static let refreshInterval = "io.brevans.PRChecker.refreshInterval"
        static let legacyQueries = "io.brevans.PRChecker.legacyQueries"
        static let displayOptions = "io.brevans.PRChecker.displayOptions"
    }
    
    @objc dynamic var userList: [String]? {
        get { stringArray(forKey: UserDefaultsKey.userList) }
        set { set(newValue, forKey: UserDefaultsKey.userList) }
    }
    
    dynamic var refreshInterval: RefreshSetting {
        get {
            let rawValue = double(forKey: UserDefaultsKey.refreshInterval)
            return RefreshSetting(rawValue: rawValue) ?? .fiveMinutes
        }
        set { set(newValue.rawValue, forKey: UserDefaultsKey.refreshInterval) }
    }
    
    @objc dynamic var useLegacyQueries: Bool {
        get { bool(forKey: UserDefaultsKey.legacyQueries) }
        set { set(newValue, forKey: UserDefaultsKey.legacyQueries) }
    }
    
    dynamic var displayOptions: DisplayOption {
        get {
            let rawValue = integer(forKey: UserDefaultsKey.displayOptions)
            return DisplayOption(rawValue: rawValue) ?? [.assigned, .reviewRequested, .reviewed]
        }
        set { set(newValue.rawValue, forKey: UserDefaultsKey.displayOptions) }
    }
}
