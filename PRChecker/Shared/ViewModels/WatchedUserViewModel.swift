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
    @Published var additionalFilters: [String: [Filter]]?
    
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
                    self.prList = (self.prList + [newEntry]).sorted { $0.0 < $1.0 }
                    
                    let labelFilters = self.prList.map(\.1).flatMap { $0 }.map(\.labels).flatMap { $0 }.map { label in
                        Filter(name: label.title) { pullRequest in
                            pullRequest.labels.contains { prLabel in
                                prLabel == label
                            }
                        }
                    }
                        .arrayByRemovingDuplicates()
                    
                    let repositoryFilters = self.prList.map(\.1).flatMap { $0 }.map(\.repositoryName).map { name in
                        Filter(name: name) { $0.repositoryName == name }
                    }
                        .arrayByRemovingDuplicates()
                    
                    self.additionalFilters = [
                        "Labels": labelFilters,
                        "Repository": repositoryFilters,
                    ]
                }
            }
            .store(in: &subscriptions)

    }
}
