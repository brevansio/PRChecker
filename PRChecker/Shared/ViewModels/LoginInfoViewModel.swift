//
//  LoginInfoViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/03.
//

import Foundation
import Apollo
import KeychainAccess

struct LoginInfoViewModel {
    var username: String
    var accessToken: String
    var apiEndpoint: String
    var useLegacyQuery: Bool
    
    var canLogin: Bool {
        !username.isEmpty && !accessToken.isEmpty && !apiEndpoint.isEmpty
    }
    
    init() {
        let keychainService = Keychain(service: KeychainKey.service)
        username = keychainService[KeychainKey.username] ?? ""
        accessToken = keychainService[KeychainKey.accessToken] ?? ""
        apiEndpoint = keychainService[KeychainKey.apiEndpoint] ?? "https://api.github.com/graphql"
        useLegacyQuery = UserDefaults.standard.bool(forKey: UserDefaultsKey.legacyQueries)
    }

    func saveToKeychain() {
        let keychainService = Keychain(service: KeychainKey.service)
        keychainService[KeychainKey.apiEndpoint] = apiEndpoint
        keychainService[KeychainKey.username] = username
        keychainService[KeychainKey.accessToken] = accessToken
        UserDefaults.standard.set(useLegacyQuery, forKey: UserDefaultsKey.legacyQueries)
        
        NetworkSerivce.shared.configure(for: username, accessToken: accessToken, endpoint: apiEndpoint, useLegacyQuery: useLegacyQuery)
    }
}

