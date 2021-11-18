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
    private var timerSubscription: AnyCancellable?
    
    init() {
        SettingsViewModel.shared.$userList
            .receive(on: DispatchQueue.main)
            .sink { userList in
                self.watchedPRList = self.watchedPRList.filter { userList.contains($0.name) }
            }
            .store(in: &subscriptions)
        
        SettingsViewModel.shared.$refreshInterval
            .receive(on: DispatchQueue.main)
            .sink { refreshSetting in
                self.timerSubscription = Timer
                    .publish(every: refreshSetting.rawValue, tolerance: 15, on: .main, in: .default)
                    .autoconnect()
                    .sink { _ in
                        self.getPRList()
                    }
            }
            .store(in: &subscriptions)
    }
    
    func getPRList(completion: (() -> Void)? = nil) {
        // TODO: Convert these to Publishers and make it work with the RefreshableScrollView
        getMyPRList(completion: completion)
        
        if !SettingsViewModel.shared.userList.isEmpty {
            getWatchedPRList(for: SettingsViewModel.shared.userList)
        }
    }
    
    func getMyPRList(completion: (() -> Void)? = nil) {
        NetworkSerivce.shared.getAllPRs()
            .receive(on: DispatchQueue.main)
            .sink { error in
                // TODO: Handle Errors
            } receiveValue: { prList in
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
            .store(in: &subscriptions)
    }
    
    func getWatchedPRList(for userList: [String]) {        
        self.watchedPRList = self.watchedPRList.filter { userList.contains($0.name) }
        
        NetworkSerivce.shared.getAllPRs(for: userList)
            .receive(on: DispatchQueue.main)
            .sink { error in
                // TODO: Handle Error
            } receiveValue: { newEntry in
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
