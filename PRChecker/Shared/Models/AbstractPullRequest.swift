//
//  AbstractPullRequest.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/09.
//

import Foundation
import Apollo
import SwiftUI

enum PRState: String {
    case open = "Open"
    case merged = "Merged"
    case closed = "Closed"
    
    var color: Color {
        switch self {
        case .open:
            return .green
        case .merged:
            return .orange
        case .closed:
            return .red
        }
    }
}

enum ViewerStatus: String {
    case waiting = "Waiting"
    case commented = "Commented"
    case blocked = "Blocked"
    case approved = "Approved"
    
    var color: Color {
        switch self {
        case .waiting:
            return .orange
        case .commented:
            return .yellow
        case .blocked:
            return .red
        case .approved:
            return .green
        }
    }
}

protocol LabelNode {
    var id: GraphQLID { get }
    var name: String { get }
    var color: String { get }
}

extension PrInfo.Label.Node: LabelNode {}
extension OldPrInfo.Label.Node: LabelNode {}

struct LabelModel {
    let labelConnection: LabelNode

    var id: GraphQLID {
        labelConnection.id
    }
    
    var title: String {
        labelConnection.name
    }
    
    var color: Color {
        return .init(hexValue: labelConnection.color)
    }
}

extension LabelModel: Equatable {
    static func == (lhs: LabelModel, rhs: LabelModel) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}

struct HeaderViewModel {
    let repoName: String
    let status: PRState
    let title: String
    let targetBranch: String
    let headBranch: String
    
}

struct ContentViewModel {
    let author: String
    let additions: String
    let deletions: String
    let commits: String
    let description: String
    let labels: [LabelModel]
}

struct FooterViewModel {
    let status: ViewerStatus
    let updatedTime: String
}

// Do not use this class directly
class AbstractPullRequest: ObservableObject, Identifiable {
    lazy var headerViewModel: HeaderViewModel = {
        HeaderViewModel(
            repoName: repositoryName,
            status: state,
            title: title,
            targetBranch: targetBranch,
            headBranch: headBranch
        )
    }()
    
    lazy var contentViewModel: ContentViewModel = {
        ContentViewModel(
            author: author,
            additions: "+\(lineAdditions)",
            deletions: "-\(lineDeletions)",
            commits: "\(commits.count) commits",
            description: body,
            labels: labels
        )
    }()
    
    lazy var footerViewModel: FooterViewModel = {
        FooterViewModel(
            status: viewerStatus,
            updatedTime: updatedAt
        )
    }()
    
    var id: GraphQLID { GraphQLID("!!") }
    
    var isRead: Bool { false }
    
    var url: String { "" }
    
    var repositoryName: String { "" }
    
    var targetBranch: String { "" }
    
    var headBranch: String { "" }
    
    var author: String { "" }
    
    var title: String { "" }
    
    var body: String { "" }
    
    var changedFileCount: Int { 0 }
    
    var lineAdditions: Int { 0 }
    
    var lineDeletions: Int { 0 }
    
    var commits: [GraphQLID] { [] }
    
    var labels: [LabelModel] { [] }
    
    var state: PRState { .closed }
    
    var viewerStatus: ViewerStatus { .waiting }
    
    var mergedAt: String? { nil }
    
    var rawUpdatedAt: String { "" }
    
    var updatedAt: String { "" }
    
    private static let dateFormatter = ISO8601DateFormatter()
    
    private static let secondsPerDay: Double = 60 * 60 * 24
    private static let secondsPerHour: Double = 60 * 60
    private static let secondsPerMinute: Double = 60
    
    class func relativeDateString(from dateString: String) -> String {
        let date = dateFormatter.date(from: dateString) ?? Date()
        let offset = abs(date.timeIntervalSinceNow)
        
        if offset / secondsPerDay > 1 {
            return "\(Int(floor(offset / secondsPerDay)))d"
        } else if offset /  secondsPerHour > 1 {
            return "\(Int(floor(offset / secondsPerHour)))h"
        } else if offset / secondsPerMinute > 1 {
            return "\(Int(floor(offset / secondsPerMinute)))m"
        } else {
            return "1m"
        }
    }
}

extension AbstractPullRequest: Equatable {
    static func == (lhs: AbstractPullRequest, rhs: AbstractPullRequest) -> Bool {
        lhs.id == rhs.id
    }
}
