//
//  MyPRManager.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/09.
//

import SwiftUI

class MyPRManager: ObservableObject {

    static var shared = MyPRManager()

    @Published var prList: [PullRequest] = []

    private init() {}
}
