//
//  PRListViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import Combine
import Foundation

class PRListViewModel: ObservableObject {

    @Published var additionalFilters: [String: [Filter]]?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        Timer.publish(every: 600, tolerance: 15, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                self.getPRList()
            }
            .store(in: &subscriptions)
    }
    
    func getPRList(completion: (() -> Void)? = nil) {
        NetworkSerivce.shared.getAllPRs()
            .sink { error in
                // TODO: Handle Errors
            } receiveValue: { prList in
                DispatchQueue.main.async {
                    MyPRManager.shared.prList = prList.1
                    
                    let labelFilters = MyPRManager.shared.prList.map(\.labels).flatMap { $0 }.map { label in
                        Filter(name: label.title) { pullRequest in
                            pullRequest.labels.contains { prLabel in
                                prLabel == label
                            }
                        }
                    }
                        .arrayByRemovingDuplicates()
                    
                    let repositoryFilters = MyPRManager.shared.prList.map(\.repositoryName).map { name in
                        Filter(name: name) { $0.repositoryName == name }
                    }
                        .arrayByRemovingDuplicates()
                    
                    self.additionalFilters = [
                        "Labels": labelFilters,
                        "Repository": repositoryFilters,
                    ]
                    completion?()
                }
            }
            .store(in: &subscriptions)
    }
}
