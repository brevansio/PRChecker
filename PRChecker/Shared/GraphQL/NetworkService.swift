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

    private var username: String
    private var accessToken: String
    private var apiEndpoint: String {
        didSet {
            guard !apiEndpoint.isEmpty else { return }
            let url = URL(string: apiEndpoint)!
            let configuration = URLSessionConfiguration.default

            let store = ApolloStore()
            configuration.httpAdditionalHeaders = ["authorization": "Bearer \(accessToken)"]

            let sessionClient = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)

            let provider = DefaultInterceptorProvider(
                client: sessionClient,
                shouldInvalidateClientOnDeinit: true,
                store: store
            )
            let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)

            apollo = ApolloClient(networkTransport: requestChainTransport, store: store)
        }
    }
    private var useLegacyQuery: Bool
    
    private init() {
        let keychainService = Keychain(service: KeychainKey.service)
        username = keychainService[KeychainKey.username] ?? ""
        accessToken = keychainService[KeychainKey.accessToken] ?? ""
        apiEndpoint = keychainService[KeychainKey.apiEndpoint] ?? "https://api.github.com/graphql"
        useLegacyQuery = UserDefaults.standard.bool(forKey: UserDefaultsKey.legacyQueries)
    }
        
    private(set) lazy var apollo: ApolloClient = {
        let url = URL(string: apiEndpoint)!
        let configuration = URLSessionConfiguration.default

        let store = ApolloStore()
        configuration.httpAdditionalHeaders = ["authorization": "Bearer \(accessToken)"]

        let sessionClient = URLSessionClient(sessionConfiguration: configuration, callbackQueue: nil)

        let provider = DefaultInterceptorProvider(
            client: sessionClient,
            shouldInvalidateClientOnDeinit: true,
            store: store
        )
        let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)

        return ApolloClient(networkTransport: requestChainTransport, store: store)
    }()
    
    func configure(for username: String, accessToken: String, endpoint: String, useLegacyQuery: Bool) {
        self.username = username
        self.accessToken = accessToken
        self.apiEndpoint = endpoint
        self.useLegacyQuery = useLegacyQuery
    }
    
    func getAllPRs() -> AnyPublisher<NetworkPRResult, Error> {
        getAllPRs(for: username)
    }
    
    func getAllPRs(for username: String) -> AnyPublisher<NetworkPRResult, Error> {
        let assignedQuery = NetworkQuery(username: username) {
            "is:pr assignee:\($0) archived:false sort:updated"
        }
        let requestedQuery = NetworkQuery(username: username) {
            "is:pr review-requested:\($0) archived:false sort:updated"
        }
        let reviewedQuery = NetworkQuery(username: username) {
            "is:pr reviewed-by:\($0) archived:false sort:updated"
        }
        
        return Publishers.Zip3(getPR(with: assignedQuery), getPR(with: requestedQuery), getPR(with: reviewedQuery))
            .map { prLists in
                (prLists.0 + prLists.1 + prLists.2)
                    .arrayByRemovingDuplicates()
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
        guard !username.isEmpty, !accessToken.isEmpty, !apiEndpoint.isEmpty else {
            return Fail(error: NetworkServiceError.missingLogin).eraseToAnyPublisher()
        }
        
        guard !useLegacyQuery else { return getOldPR(with: networkQuery) }
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
                    .filter { $0.author?.login != self.username }
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
                    .filter { $0.author?.login != self.username }
                    .map {
                        OldPullRequest(pullRequest: $0, currentUser: networkQuery.username, viewingUser: self.username)
                    }
                
                resultPublisher.send(resultList)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        return resultPublisher.eraseToAnyPublisher()
    }
}
