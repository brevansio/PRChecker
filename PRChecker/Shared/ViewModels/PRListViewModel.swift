//
//  PRListViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import Combine
import Foundation
import SwiftUI

class PRListViewModel: ObservableObject {
    
    @Published var prList = [PullRequest]()
    @Published var additionalFilters: [String: [Filter]]?
    
    private var subscriptions = Set<AnyCancellable>()
    
    func getPRList(completion: (() -> Void)? = nil)  {
        NetworkSerivce.shared.getAllPRs()
            .sink { error in
                // TODO: Handle Errors
            } receiveValue: { prList in
                DispatchQueue.main.async {
                    self.prList = prList
                    
                    let labelFilters = prList.map(\.labels).flatMap { $0 }.map { label in
                        Filter(name: label.title) { pullRequest in
                            pullRequest.labels.contains { prLabel in
                                prLabel == label
                            }
                        }
                    }
                        .removingLaterDuplicates()
                    
                    let repositoryFilters = prList.map(\.repositoryName).map { name in
                        Filter(name: name) { $0.repositoryName == name }
                    }
                        .removingLaterDuplicates()
                    
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
