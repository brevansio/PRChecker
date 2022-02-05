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

extension DisplayOption {
    func queries(for username: String) -> [NetworkQuery] {
        var queries = [NetworkQuery]()
        
        if contains(.assigned) {
            queries.append(
                NetworkQuery(username: username) { "is:pr assignee:\($0) archived:false sort:updated" }
            )
        }
        if contains(.reviewRequested) {
            queries.append(
                NetworkQuery(username: username) { "is:pr review-requested:\($0) archived:false sort:updated" }
            )
        }
        if contains(.reviewed) {
            queries.append(
                NetworkQuery(username: username) { "is:pr reviewed-by:\($0) archived:false sort:updated" }
            )
        }
        
        return queries
    }
}

final class NetworkSerivce {
    static let shared = NetworkSerivce()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        SettingsViewModel.shared.loginViewModel.objectWillChange
            .debounce(for: .seconds(0.75), scheduler: RunLoop.main)
            .sink { _ in
                DispatchQueue.main.async {
                    guard SettingsViewModel.shared.loginViewModel.canLogin else { return }
                    self.apollo = self.generateClient()
                }
            }
            .store(in: &subscriptions)
    }
        
    private(set) lazy var apollo: ApolloClient = generateClient()
    
    private func generateClient() -> ApolloClient {
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
    }
    
    func getAllMyReviews() -> AnyPublisher<NetworkPRResult, Error> {
        getAllReviews(for: SettingsViewModel.shared.loginViewModel.username)
    }
    
    func getAllReviews(for username: String) -> AnyPublisher<NetworkPRResult, Error> {
        let publishers = SettingsViewModel.shared.displayOptions.queries(for: username)
            .map { self.getReviews(with: $0) }
        
        guard !publishers.isEmpty else { return Fail(error: NetworkServiceError.missingQuery).eraseToAnyPublisher() }
        
        return Publishers.MergeMany(publishers)
            .collect(publishers.count)
            .map { prList in
                prList.flatMap { $0 }
                    .arrayByRemovingDuplicates()
                    .sorted { $0.rawUpdatedAt > $1.rawUpdatedAt }
            }
            .map { prList in
                NetworkPRResult(name: username, pullRequests: prList)
            }
            .eraseToAnyPublisher()
    }
    
    func getAllReviews(for usernameList: [String]) -> AnyPublisher<NetworkPRResult, Error> {
        Publishers.MergeMany(usernameList.map(getAllReviews(for:)))
            .eraseToAnyPublisher()
    }
    
    func getReviews(with networkQuery: NetworkQuery) -> AnyPublisher<[AbstractPullRequest], Error> {
        guard !SettingsViewModel.shared.loginViewModel.username.isEmpty, !SettingsViewModel.shared.loginViewModel.accessToken.isEmpty, !SettingsViewModel.shared.loginViewModel.apiEndpoint.isEmpty else {
            return Fail(error: NetworkServiceError.missingLogin).eraseToAnyPublisher()
        }
        
        return getReviewList(with: networkQuery)
    }
}

extension NetworkSerivce {
    func getReviewList(with networkQuery: NetworkQuery) -> AnyPublisher<[AbstractPullRequest], Error> {
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
                    .filter { $0.author?.login.lowercased() != networkQuery.username.lowercased() }
                    .map {
                        PullRequest(pullRequest: $0, currentUser: networkQuery.username)
                    }
                resultPublisher.send(resultList)
                resultPublisher.send(completion: .finished)
            case .failure(let error):
                resultPublisher.send(completion: .failure(error))
            }
        }
        
        return resultPublisher.eraseToAnyPublisher()
    }
}
