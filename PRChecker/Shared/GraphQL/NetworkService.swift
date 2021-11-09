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
    
    private init() {
        let keychainService = Keychain(service: KeychainKey.service)
        username = keychainService[KeychainKey.username] ?? ""
        accessToken = keychainService[KeychainKey.accessToken] ?? ""
        apiEndpoint = keychainService[KeychainKey.apiEndpoint] ?? "https://api.github.com/graphql"
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
    
    func initialize(for username: String, accessToken: String, endpoint: String) {
        self.username = username
        self.accessToken = accessToken
        self.apiEndpoint = endpoint
    }
    
    func getAllPRs() -> AnyPublisher<(String, [AbstractPullRequest]), Error> {
        getAllPRs(for: username)
    }
    
    func getAllPRs(for username: String) -> AnyPublisher<(String, [AbstractPullRequest]), Error> {
        let assignedQuery = "is:pr assignee:\(username) archived:false"
        let requestedQuery = "is:pr review-requested:\(username) archived:false"
        
        return Publishers.Zip(getPR(with: assignedQuery), getPR(with: requestedQuery))
            .map { prLists in
                (prLists.0 + prLists.1).sorted { $0.rawUpdatedAt > $1.rawUpdatedAt }
            }
            .map{ prList in
                (username, prList)
            }
            .eraseToAnyPublisher()
    }
    
    func getPR(with query: String) -> AnyPublisher<[AbstractPullRequest], Error> {
        let resultPublisher = PassthroughSubject<[AbstractPullRequest], Error>()
        
        guard !username.isEmpty, !accessToken.isEmpty, !apiEndpoint.isEmpty else {
            resultPublisher.send(completion: .failure(NetworkServiceError.missingLogin))
            return resultPublisher.eraseToAnyPublisher()
        }
        
        apollo.fetch(
            query: GetAssignedPRsWithQueryQuery(query: query),
            cachePolicy: .fetchIgnoringCacheData
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let prList = graphQLResult.data?.search.edges?.map(\.?.node?.asPullRequest?.fragments.prInfo)
                else {
                    resultPublisher.send(completion: .failure(NetworkServiceError.decodingIssue))
                    return
                }
                let resultList = prList.compactMap { $0 }
                    .map(PullRequest.init)
                resultPublisher.send(resultList)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        return resultPublisher.eraseToAnyPublisher()
    }
    
    func getAllPRs(for usernameList: [String]) -> AnyPublisher<(String, [AbstractPullRequest]), Error> {
        Publishers.MergeMany(usernameList.map(getAllPRs(for:)))
            .eraseToAnyPublisher()
    }
}

extension NetworkSerivce {
    func getAllOldPRs() -> AnyPublisher<(String, [AbstractPullRequest]), Error> {
        getAllOldPRs(for: username)
    }
    
    func getAllOldPRs(for username: String) -> AnyPublisher<(String, [AbstractPullRequest]), Error> {
        let assignedQuery = "is:pr assignee:\(username) archived:false"
        let requestedQuery = "is:pr review-requested:\(username) archived:false"
        
        return Publishers.Zip(getOldPR(with: assignedQuery), getOldPR(with: requestedQuery))
            .map { prLists in
                (prLists.0 + prLists.1).sorted { $0.rawUpdatedAt > $1.rawUpdatedAt }
            }
            .map{ prList in
                (username, prList)
            }
            .eraseToAnyPublisher()
    }
    
    func getOldPR(with query: String) -> AnyPublisher<[AbstractPullRequest], Error> {
        let resultPublisher = PassthroughSubject<[AbstractPullRequest], Error>()
        
        guard !username.isEmpty, !accessToken.isEmpty, !apiEndpoint.isEmpty else {
            resultPublisher.send(completion: .failure(NetworkServiceError.missingLogin))
            return resultPublisher.eraseToAnyPublisher()
        }
        
        apollo.fetch(
            query: GetOldAssignedPRsWithQueryQuery(query: query),
            cachePolicy: .fetchIgnoringCacheData
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let prList = graphQLResult.data?.search.edges?.map(\.?.node?.asPullRequest?.fragments.oldPrInfo)
                else {
                    resultPublisher.send(completion: .failure(NetworkServiceError.decodingIssue))
                    return
                }
                let resultList = prList.compactMap { $0 }
                    .map {
                        OldPullRequest(pullRequest: $0, username: self.username)
                    }
                resultPublisher.send(resultList)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        return resultPublisher.eraseToAnyPublisher()
    }
    
    func getAllOldPRs(for usernameList: [String]) -> AnyPublisher<(String, [AbstractPullRequest]), Error> {
        Publishers.MergeMany(usernameList.map(getAllOldPRs(for:)))
            .eraseToAnyPublisher()
    }
}
