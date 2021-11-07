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

final class NetworkSerivce {
    static let shared = NetworkSerivce()

    private var username: String
    private var accessToken: String
    private var apiEndpoint: String
    
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
    
    func getAllPRs() -> AnyPublisher<[PullRequest], Error> {
        let assignedQuery = "is:pr assignee:\(username) archived:false"
        let requestedQuery = "is:pr review-requested:\(username) archived:false"
        
        let resultPublisher = CurrentValueSubject<[PullRequest], Error>([])
        
        apollo.fetch(
            query: GetAssignedPRsWithQueryQuery(query: assignedQuery),
            cachePolicy: .fetchIgnoringCacheData
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let prList = graphQLResult.data?.search.edges?.map(\.?.node?.asPullRequest?.fragments.prInfo)
                else {
                    // TODO: Error to the Publisher
                    return
                }
                let resultList = prList.compactMap { $0 }
                    .map(PullRequest.init)
                resultPublisher.send(resultPublisher.value + resultList)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        apollo.fetch(
            query: GetAssignedPRsWithQueryQuery(query: requestedQuery),
            cachePolicy: .fetchIgnoringCacheData
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let prList = graphQLResult.data?.search.edges?.map(\.?.node?.asPullRequest?.fragments.prInfo)
                else {
                    // TODO: Send an error to the publisher
                    return
                }
                let resultList = prList.compactMap { $0 }
                    .map(PullRequest.init)
                resultPublisher.send(resultPublisher.value + resultList)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        return resultPublisher.eraseToAnyPublisher()
    }
}
