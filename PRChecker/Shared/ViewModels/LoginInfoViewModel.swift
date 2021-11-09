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
        useLegacyQuery = keychainService[KeychainKey.legacyQueryFlag] != nil ? true : false
    }

    func saveToKeychain() {
        let keychainService = Keychain(service: KeychainKey.service)
        keychainService[KeychainKey.apiEndpoint] = apiEndpoint
        keychainService[KeychainKey.username] = username
        keychainService[KeychainKey.accessToken] = accessToken
        keychainService[KeychainKey.legacyQueryFlag] = useLegacyQuery ? "1" : nil
        
        NetworkSerivce.shared.initialize(for: username, accessToken: accessToken, endpoint: apiEndpoint, useLegacyQuery: useLegacyQuery)
    }
}

