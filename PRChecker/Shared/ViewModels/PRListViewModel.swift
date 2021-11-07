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
    @Published var labelFilters: [Filter]?
    
    private var subscriptions = Set<AnyCancellable>()
    
    func getPRList() {
        NetworkSerivce.shared.getAllPRs()
            .sink { error in
                // TODO: Handle Errors
            } receiveValue: { prList in
                DispatchQueue.main.async {
                    self.prList = prList
                    
                    self.labelFilters = prList.map(\.labels).flatMap { $0 }.map { label in
                        Filter(name: label.title) { pullRequest in
                            pullRequest.labels.contains { prLabel in
                                prLabel == label
                            }
                        }
                    }
                }
            }
            .store(in: &subscriptions)
    }
}
