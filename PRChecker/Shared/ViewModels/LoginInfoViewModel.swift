//
//  LoginInfoViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/03.
//

import Foundation
import Apollo
import KeychainAccess

class LoginInfoViewModel: ObservableObject {
    @Published var username: String
    @Published var accessToken: String
    @Published var apiEndpoint: String
    
    var canLogin: Bool {
        !username.isEmpty && !accessToken.isEmpty && !apiEndpoint.isEmpty
    }
    
    init() {
        let keychainService = Keychain(service: KeychainKey.service)
        username = keychainService[KeychainKey.username] ?? ""
        accessToken = keychainService[KeychainKey.accessToken] ?? ""
        apiEndpoint = keychainService[KeychainKey.apiEndpoint] ?? "https://api.github.com/graphql"
    }

    func save() {
        let keychainService = Keychain(service: KeychainKey.service)
        keychainService[KeychainKey.apiEndpoint] = apiEndpoint
        keychainService[KeychainKey.username] = username
        keychainService[KeychainKey.accessToken] = accessToken
    }
}

