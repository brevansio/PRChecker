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
                guard refreshSetting != .never else {
                    self.timerSubscription = nil
                    return
                }
                self.timerSubscription = Timer
                    .publish(every: refreshSetting.rawValue, tolerance: 15, on: .main, in: .default)
                    .autoconnect()
                    .sink { _ in
                        self.getMyPRList()
                    }
            }
            .store(in: &subscriptions)
    }
    
    func getPRList(completion: (() -> Void)? = nil) {
        if !SettingsViewModel.shared.userList.isEmpty {
            getWatchedPRList(for: SettingsViewModel.shared.userList)
        }
        getMyPRList(completion: completion)
    }
    
    func getMyPRList(completion: (() -> Void)? = nil) {
        NetworkSerivce.shared.getAllMyReviews()
            .receive(on: DispatchQueue.main)
            .sink { termination in
                guard case .failure(let error) = termination else {
                    completion?()
                    return
                }
                MyPRManager.shared.prList = []
                completion?()
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
            }
            .store(in: &self.subscriptions)
    }
    
    func getWatchedPRList(for userList: [String]) {        
        self.watchedPRList = self.watchedPRList.filter { userList.contains($0.name) }
        
        NetworkSerivce.shared.getAllReviews(for: userList)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    // TODO: Handle Error
                    self.watchedPRList = []
                }
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
