//
//  NetworkService.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/03.
//

import Apollo
import Combine
import Foundation
import KeychainAccess

enum NetworkServiceError: Error {
    case missingLogin
    case decodingIssue
    case missingQuery
}

struct NetworkPRResult: Equatable {
    let name: String
    let pullRequests: [AbstractPullRequest]
    
    static func == (lhs: NetworkPRResult, rhs: NetworkPRResult) -> Bool {
        lhs.name == rhs.name
    }
}

struct NetworkQuery {
    let username: String
    let query: (String) -> String
    
    var completedQuery: String { query(username) }
}

final class NetworkSerivce {
    static let shared = NetworkSerivce()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        // Because of the debounce, we still need the lazy setter for apollo. Because of that, we also need to
        // dropFirst, otherwise we end up missing our first set of results. We need the debouce because typing will
        // trigger this, and we don't need that many resets of our apollo client.
        SettingsViewModel.shared.loginViewModel.$apiEndpoint
            .dropFirst()
            .debounce(for: .seconds(0.75), scheduler: RunLoop.main)
            .sink { newEndpoint in
                guard !newEndpoint.isEmpty else { return }
                let url = URL(string: newEndpoint)!
                let configuration = URLSessionConfiguration.default
                
                let store = ApolloStore()
                configuration.httpAdditionalHeaders = ["authorization": "Bearer \(SettingsViewModel.shared.loginViewModel.accessToken)"]
                
                let sessionClient = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)
                
                let provider = DefaultInterceptorProvider(
                    client: sessionClient,
                    shouldInvalidateClientOnDeinit: true,
                    store: store
                )
                let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)
                
                self.apollo = ApolloClient(networkTransport: requestChainTransport, store: store)                
            }
            .store(in: &subscriptions)
    }
        
    private(set) lazy var apollo: ApolloClient = {
        let url = URL(string: SettingsViewModel.shared.loginViewModel.apiEndpoint)!
        let configuration = URLSessionConfiguration.default

        let store = ApolloStore()
        configuration.httpAdditionalHeaders = ["authorization": "Bearer \(SettingsViewModel.shared.loginViewModel.accessToken)"]

        let sessionClient = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)

        let provider = DefaultInterceptorProvider(
            client: sessionClient,
            shouldInvalidateClientOnDeinit: true,
            store: store
        )
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)

        return ApolloClient(networkTransport: requestChainTransport, store: store)
    }()
    
    func getAllPRs() -> AnyPublisher<NetworkPRResult, Error> {
        getAllPRs(for: SettingsViewModel.shared.loginViewModel.username)
    }
    
    func getAllPRs(for username: String) -> AnyPublisher<NetworkPRResult, Error> {
        var publishers = [AnyPublisher<[AbstractPullRequest], Error>]()
        
        if SettingsViewModel.shared.displayOptions.contains(.assigned) {
            let assignedQuery = NetworkQuery(username: username) {
                "is:pr assignee:\($0) archived:false sort:updated"
            }
            publishers.append(getPR(with: assignedQuery))
        }
        if SettingsViewModel.shared.displayOptions.contains(.reviewRequested) {
            let requestedQuery = NetworkQuery(username: username) {
                "is:pr review-requested:\($0) archived:false sort:updated"
            }
            publishers.append(getPR(with: requestedQuery))
        }
        if SettingsViewModel.shared.displayOptions.contains(.reviewed) {
            let reviewedQuery = NetworkQuery(username: username) {
                "is:pr reviewed-by:\($0) archived:false sort:updated"
            }
            publishers.append( getPR(with: reviewedQuery))
        }
        
        guard !publishers.isEmpty else { return Fail(error: NetworkServiceError.missingQuery).eraseToAnyPublisher() }
        
        return Publishers.MergeMany(publishers)
            .map { prList in
                prList.arrayByRemovingDuplicates()
                    .sorted { $0.rawUpdatedAt > $1.rawUpdatedAt }
            }
            .map{ prList in
                NetworkPRResult(name: username, pullRequests: prList)
            }
            .eraseToAnyPublisher()
    }
    
    func getAllPRs(for usernameList: [String]) -> AnyPublisher<NetworkPRResult, Error> {
        Publishers.MergeMany(usernameList.map(getAllPRs(for:)))
            .eraseToAnyPublisher()
    }
    
    func getPR(with networkQuery: NetworkQuery) -> AnyPublisher<[AbstractPullRequest], Error> {
        guard !SettingsViewModel.shared.loginViewModel.username.isEmpty, !SettingsViewModel.shared.loginViewModel.accessToken.isEmpty, !SettingsViewModel.shared.loginViewModel.apiEndpoint.isEmpty else {
            return Fail(error: NetworkServiceError.missingLogin).eraseToAnyPublisher()
        }
        
        guard !SettingsViewModel.shared.loginViewModel.useLegacyQuery else { return getOldPR(with: networkQuery) }
        return getNewPR(with: networkQuery)
    }
}

extension NetworkSerivce {
    func getNewPR(with networkQuery: NetworkQuery) -> AnyPublisher<[AbstractPullRequest], Error> {
        let resultPublisher = PassthroughSubject<[AbstractPullRequest], Error>()
        
        apollo.fetch(
            query: GetAssignedPRsWithQueryQuery(query: networkQuery.completedQuery),
            cachePolicy: .fetchIgnoringCacheData,
            queue: .global(qos: .userInitiated)
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let prList = graphQLResult.data?.search.edges?.map(\.?.node?.asPullRequest?.fragments.prInfo)
                else {
                    resultPublisher.send(completion: .failure(NetworkServiceError.decodingIssue))
                    return
                }
                let resultList = prList.compactMap { $0 }
                    .filter { $0.author?.login != SettingsViewModel.shared.loginViewModel.username }
                    .map {
                        PullRequest(pullRequest: $0, currentUser: networkQuery.username)
                    }
                resultPublisher.send(resultList)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        return resultPublisher.eraseToAnyPublisher()
    }
}

extension NetworkSerivce {
    func getOldPR(with networkQuery: NetworkQuery) -> AnyPublisher<[AbstractPullRequest], Error> {
        let resultPublisher = PassthroughSubject<[AbstractPullRequest], Error>()
        
        apollo.fetch(
            query: GetOldAssignedPRsWithQueryQuery(query: networkQuery.completedQuery),
            cachePolicy: .fetchIgnoringCacheData,
            queue: .global(qos: .userInitiated)
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let prList = graphQLResult.data?.search.edges?.map(\.?.node?.asPullRequest?.fragments.oldPrInfo)
                else {
                    resultPublisher.send(completion: .failure(NetworkServiceError.decodingIssue))
                    return
                }
                let resultList = prList.compactMap { $0 }
                    .filter { $0.author?.login != SettingsViewModel.shared.loginViewModel.username }
                    .map {
                        OldPullRequest(pullRequest: $0, currentUser: networkQuery.username, viewingUser: SettingsViewModel.shared.loginViewModel.username)
                    }
                
                resultPublisher.send(resultList)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        return resultPublisher.eraseToAnyPublisher()
    }
}
