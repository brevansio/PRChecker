//
//  PullRequest.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/03.
//

import Foundation
import Apollo
import SwiftUI

class PullRequest: AbstractPullRequest {
    let pullRequest: PrInfo
    
    init(pullRequest: PrInfo, currentUser: String) {
        self.pullRequest = pullRequest
        super.init(currentUser: currentUser)
    }
    
    override var id: GraphQLID {
        pullRequest.id
    }
    
    override var isRead: Bool {
        pullRequest.isReadByViewer ?? false
    }
    
    override var url: String {
        pullRequest.url
    }
    
    override var repositoryName: String {
        pullRequest.repository.nameWithOwner
    }
    
    override var targetBranch: String {
        pullRequest.baseRefName
    }
    
    override var headBranch: String {
        pullRequest.headRefName
    }
    
    override var author: String {
        pullRequest.author?.login ?? "Unknown"
    }
    
    override var title: String {
        pullRequest.title
    }
    
    override var body: String {
        pullRequest.body
    }
    
    override var changedFileCount: Int {
        pullRequest.changedFiles
    }
    
    override var lineAdditions: Int {
        pullRequest.additions
    }
    
    override var lineDeletions: Int {
        pullRequest.deletions
    }
    
    override var commits: [GraphQLID] {
        pullRequest.commits.nodes?.compactMap { $0 }.map(\.id) ?? []
    }
    
    override var labels: [LabelModel] {
        pullRequest.labels?.nodes?.compactMap { $0 }.map(LabelModel.init) ?? []
    }
    
    override var state: PRState {
        switch pullRequest.state {
        case .open:
            return .open
        case .merged:
            return .merged
        case .closed:
            return .closed
        default:
            fatalError("Unknown state: \(String(describing: pullRequest.state))")
        }
    }
    
    override var reviewStatus: ReviewStatus {
        guard let nodes = pullRequest.reviews?.nodes else {
            return .waiting     // No reviews at all
        }
        
        guard
            let viewersReview = nodes.last(where: { $0?.author?.login.lowercased() == currentUser.lowercased() })
        else {
            return .waiting     // Viewer has not reviewed
        }
        
        switch viewersReview?.state {
        case .none, .pending, .dismissed:
            return .waiting
        case .approved:
            return .approved
        case .changesRequested:
            return .blocked
        case .commented:
            return .commented
        default:
            assertionFailure("Unknown status: \(String(describing: viewersReview?.state))")
            return .waiting
        }
    }
    
    override var mergedAt: String? {
        guard let mergedAt = pullRequest.mergedAt else {
            return nil
        }

        return Self.relativeDateString(from: mergedAt)
    }
    
    override var rawUpdatedAt: String {
        pullRequest.updatedAt
    }
    
    override var updatedAt: String {
        Self.relativeDateString(from: pullRequest.updatedAt)
    }
}
