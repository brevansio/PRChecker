//
//  WatchedUserViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import Combine
import Foundation

class WatchedUserViewModel: ObservableObject {
    @Published var prList = [(String, [PullRequest])]()
    
    private var subscriptions = Set<AnyCancellable>()
    private var userList: [String]
    
    init() {
        userList = (UserDefaults.standard.array(forKey: UserDefaultsKey.userList) as? [String]) ?? []
    }
    
    func getPRList(completion: (() -> Void)? = nil) {
        NetworkSerivce.shared.getAllPRs(for: userList)
            .sink { error in
                // TODO: Handle Error
            } receiveValue: { newEntry in
                DispatchQueue.main.async {
                    self.prList.append(newEntry)
                }
            }
            .store(in: &subscriptions)

    }
}
