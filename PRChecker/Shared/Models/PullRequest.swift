//
//  PullRequest.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/03.
//

import Foundation
import Apollo

enum PRState {
    case open
    case merged
}

enum ViewerStatus {
    case waiting
    case commented
    case blocked
    case approved
}

struct PullRequest {
    let pullRequest: PrInfo
    
    var id: GraphQLID {
        pullRequest.id
    }
    
    var isRead: Bool {
        pullRequest.isReadByViewer ?? false
    }
    
    var url: String {
        pullRequest.url
    }
    
    var repositoryName: String {
        pullRequest.repository.name
    }
    
    var targetBranch: String {
        pullRequest.baseRefName
    }
    
    var headBranch: String {
        pullRequest.headRefName
    }
    
    var number: Int {
        pullRequest.number
    }
    
    var title: String {
        pullRequest.title
    }
    
    var body: String {
        pullRequest.body
    }
    
    var changedFileCount: Int {
        pullRequest.changedFiles
    }
    
    var lineAdditions: Int {
        pullRequest.additions
    }
    
    var lineDeletions: Int {
        pullRequest.deletions
    }
    
    var state: PRState {
        switch pullRequest.state {
        case .open:
            return .open
        case .merged:
            return .merged
        default:
            fatalError("This is unreachable because our query won't allow it")
        }
    }
    
    var viewerStatus: ViewerStatus {
        switch pullRequest.viewerLatestReview?.state {
        case .none, .pending, .dismissed:
            return .waiting
        case .approved:
            return .approved
        case .changesRequested:
            return .blocked
        case .commented:
            return .commented
        default:
            assertionFailure("Unknown status: \(String(describing: pullRequest.viewerLatestReview?.state))")
            return .waiting
        }
    }
    
    var mergedAt: String? {
        pullRequest.mergedAt
    }
    
    
}
