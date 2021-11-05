//
//  LoginInfoViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/03.
//

import Foundation
import Apollo
import KeychainAccess

private enum KeychainKey {
    static let service = "io.brevans.PRChecker"
    static let apiEndpoint = "API_ENDPOINT_URL"
    static let username = "USERNAME"
    static let accessToken = "ACCESST_TOKEN"
}

struct LoginInfoViewModel {
    var username: String
    var accessToken: String
    var apiEndpoint: String
    
    var canLogin: Bool {
        !username.isEmpty && !accessToken.isEmpty && !apiEndpoint.isEmpty
    }
    
    init() {
        let keychainService = Keychain(service: KeychainKey.service)
        apiEndpoint = keychainService[KeychainKey.apiEndpoint] ?? ""
        username = keychainService[KeychainKey.username] ?? ""
        accessToken = keychainService[KeychainKey.accessToken] ?? "https://api.github.com/graphql"
    }

    func saveToKeychain() {
        let keychainService = Keychain(service: KeychainKey.service)
        keychainService[KeychainKey.apiEndpoint] = apiEndpoint
        keychainService[KeychainKey.username] = username
        keychainService[KeychainKey.accessToken] = accessToken
    }
}

