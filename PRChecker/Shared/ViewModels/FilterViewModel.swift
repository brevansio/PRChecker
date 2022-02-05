//
//  FilterViewModel.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import Foundation

class FilterViewModel: ObservableObject {
    
    static let statusFilter: FilterSection = {
        FilterSection(
            name: "Status",
            type: .state,
            filters: [
                Filter(name: "Open") { $0.state == .open },
                Filter(name: "Merged") { $0.state == .merged },
            ]
        )
    }()
    
    static let reviewStatusFilter: FilterSection = {
        FilterSection(
            name: "Review Status",
            type: .reviewStatus,
            filters: [
                Filter(name: "Waiting") { $0.reviewStatus == .waiting },
                Filter(name: "Blocked") { $0.reviewStatus == .blocked },
                Filter(name: "Commented") { $0.reviewStatus == .commented },
                Filter(name: "Approved") { $0.reviewStatus == .approved },
            ]
        )
    }()
    
    @Published var sections: [FilterSection] = [
        FilterViewModel.statusFilter,
        FilterViewModel.reviewStatusFilter,
        FilterSection(name: "Labels", type: .tag, filters: []),
        FilterSection(name: "Repository", type: .repositoryName, filters: []),
    ]
    
    @Published var combinedFilter: Filter?
    
    func updateFilters() {
        combinedFilter = sections.compactMap(\.combinedFilter).reduce(nil) { partialResult, filter in
            guard let partialResult = partialResult else {
                return filter
            }
            return partialResult + filter
        }
    }
}

class FilterSection: ObservableObject {
    var name: String
    var type: PRItemType
    
    @Published var filters: [Filter]
    
    var combinedFilter: Filter?
    
    init(name: String, type: PRItemType, filters: [Filter]) {
        self.name = name
        self.type = type
        self.filters = filters
    }
    
    func updateFilters() {
        let enabledfilters = filters.filter { $0.isEnabled }
        guard !enabledfilters.isEmpty else {
            combinedFilter = nil
            return
        }
        combinedFilter = enabledfilters.reduce(nil, { partialResult, filter in
            guard let partialResult = partialResult else {
                return filter
            }
            return partialResult | filter
        })
    }
}

extension FilterSection: Equatable {
    static func == (lhs: FilterSection, rhs: FilterSection) -> Bool {
        lhs.name == rhs.name
    }
}

class Filter: ObservableObject {
    var name: String
    
    var filter: (AbstractPullRequest) -> Bool
    
    @Published var isEnabled: Bool = false
    
    init(name: String, filter: @escaping (AbstractPullRequest) -> Bool) {
        self.name = name
        self.filter = filter
    }
}

extension Filter {
    static func +(lhs: Filter, rhs: Filter) -> Filter {
        Filter(name: "\(lhs.name) AND \(rhs.name)") { pullRequest in
            lhs.filter(pullRequest) && rhs.filter(pullRequest)
        }
    }
    
    static func |(lhs: Filter, rhs: Filter) -> Filter {
        Filter(name: "\(lhs.name) OR \(rhs.name)") { pullRequest in
            lhs.filter(pullRequest) || rhs.filter(pullRequest)
        }
    }
}

extension Filter: Equatable {
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.name == rhs.name
    }
}
