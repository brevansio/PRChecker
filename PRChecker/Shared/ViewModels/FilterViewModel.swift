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
            filters: [
                Filter(name: "Open") { $0.state == .open },
                Filter(name: "Merged") { $0.state == .merged },
            ]
        )
    }()
    
    static let reviewStatusFilter: FilterSection = {
        FilterSection(
            name: "Review Status",
            filters: [
                Filter(name: "Waiting") { $0.viewerStatus == .waiting },
                Filter(name: "Blocked") { $0.viewerStatus == .blocked },
                Filter(name: "Commented") { $0.viewerStatus == .commented },
                Filter(name: "Approved") { $0.viewerStatus == .approved },
            ]
        )
    }()
    
    lazy var sections: [FilterSection] = [
        Self.statusFilter,
        Self.reviewStatusFilter,
        // TODO: Label Filter
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
    
    var filters: [Filter]
    
    var combinedFilter: Filter?
    
    init(name: String, filters: [Filter]) {
        self.name = name
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

class Filter: ObservableObject {
    var name: String
    
    var filter: (PullRequest) -> Bool
    
    var isEnabled: Bool = false
    
    init(name: String, filter: @escaping (PullRequest) -> Bool) {
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
