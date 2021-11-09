//
//  Constants.swift
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
    static let legacyQueryFlag = "LEGACY_QUERY_FLAG"
}

enum UserDefaultsKey {
    static let userList = "io.brevans.PPRChecker.userList"
}
