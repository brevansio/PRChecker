//
//  PRListViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import Combine
import Foundation

class PRListViewModel: ObservableObject {
    
    @Published var prList = [PullRequest]()
    
    private var subscriptions = Set<AnyCancellable>()
    
    func getPRList() {
        NetworkSerivce.shared.getAllPRs()
            .sink { error in
                // TODO: Handle Errors
            } receiveValue: { prList in
                DispatchQueue.main.async {
                    self.prList = prList
                }
            }
            .store(in: &subscriptions)
    }
}
