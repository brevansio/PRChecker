//
//  PRListViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import Combine
import Foundation

class PRListViewModel: ObservableObject {

    @Published var watchedPRList = [NetworkPRResult]()
    @Published var additionalFilters: [String: [Filter]]?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        UserDefaults.standard
            .publisher(for: \.userList)
            .sink { userList in
                guard let userList = userList else { return }
                self.getWatchedPRList(for: userList)
            }
            .store(in: &subscriptions)
    }
    
    func getPRList(completion: (() -> Void)? = nil) {
        // TODO: Convert these to Publishers and make it work with the RefreshableScrollView
        getMyPRList(completion: completion)
        
        if let watchedUsers = UserDefaults.standard.userList {
            getWatchedPRList(for: watchedUsers)
        }
    }
    
    func getMyPRList(completion: (() -> Void)? = nil) {
        NetworkSerivce.shared.getAllPRs()
            .sink { error in
                // TODO: Handle Errors
            } receiveValue: { prList in
                DispatchQueue.main.async {
                    MyPRManager.shared.prList = prList.pullRequests
                    
                    let labelFilters = MyPRManager.shared.prList
                        .map(\.labels)
                        .flatMap { $0 }
                        .map { label in
                            Filter(name: label.title) { pullRequest in
                                pullRequest.labels.contains { prLabel in
                                    prLabel == label
                                }
                            }
                        }
                        .arrayByRemovingDuplicates()
                    
                    let repositoryFilters = MyPRManager.shared.prList
                        .map(\.repositoryName)
                        .map { name in
                            Filter(name: name) { $0.repositoryName == name }
                        }
                        .arrayByRemovingDuplicates()
                    
                    self.updateAdditionalFilters(with: ["Labels": labelFilters, "Repository": repositoryFilters])
                    completion?()
                }
            }
            .store(in: &subscriptions)
    }
    
    func getWatchedPRList(for userList: [String]) {
        watchedPRList = watchedPRList.filter { userList.contains($0.name) }
        
        NetworkSerivce.shared.getAllPRs(for: userList)
            .sink { error in
                // TODO: Handle Error
            } receiveValue: { newEntry in
                DispatchQueue.main.async {
                    self.watchedPRList = ([newEntry] + self.watchedPRList)
                        .arrayByRemovingDuplicates()
                        .sorted { $0.name < $1.name }
                    
                    let labelFilters = self.watchedPRList
                        .map(\.pullRequests)
                        .flatMap { $0 }
                        .map(\.labels)
                        .flatMap { $0 }
                        .map { label in
                            Filter(name: label.title) { pullRequest in
                                pullRequest.labels.contains { prLabel in
                                    prLabel == label
                                }
                            }
                        }
                        .arrayByRemovingDuplicates()
                    
                    let repositoryFilters = self.watchedPRList
                        .map(\.pullRequests)
                        .flatMap { $0 }
                        .map(\.repositoryName)
                        .map { name in
                            Filter(name: name) { $0.repositoryName == name }
                        }
                        .arrayByRemovingDuplicates()
                    
                    self.updateAdditionalFilters(with: ["Labels": labelFilters, "Repository": repositoryFilters])
                }
            }
            .store(in: &subscriptions)
    }
    
    private func updateAdditionalFilters(with filters: [String: [Filter]]?) {
        var existingFilters = additionalFilters ?? [:]
        
        let labelFilters = (existingFilters["Labels"] ?? []) + (filters?["Labels"] ?? [])
        if !labelFilters.isEmpty {
            existingFilters["Labels"] = labelFilters.arrayByRemovingDuplicates().sorted { $0.name < $1.name }
        }
        
        let repoFilters = (existingFilters["Repository"] ?? []) + (filters?["Repository"] ?? [])
        if !repoFilters.isEmpty {
            existingFilters["Repository"] = repoFilters.arrayByRemovingDuplicates().sorted { $0.name < $1.name }
        }
        
        additionalFilters = existingFilters
    }
}
