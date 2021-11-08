//
//  PRListView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import SwiftUI

struct PRListView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var filterViewModel: FilterViewModel
    
    @ObservedObject var prListViewModel = PRListViewModel()
    @StateObject var watchedUserViewModel = WatchedUserViewModel()
    
    var body: some View {
        RefreshableScrollView(onRefresh: { completion in
            prListViewModel.getPRList() {
                completion()
            }
            watchedUserViewModel.getPRList()
        }) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading, pinnedViews: [.sectionHeaders]) {
                
                if let filteredPRList = prListViewModel.prList.filter(filterViewModel.combinedFilter?.filter ?? { _ in true }), !filteredPRList.isEmpty {
                    Section(header: Rectangle().frame(height: 45).foregroundColor(.gray5).overlay(Text("You").font(.title).bold().padding(.leading), alignment: .leading)) {
                        ForEach(filteredPRList, id: \.id) { pullRequest in
                            PullRequestCell(pullRequest: pullRequest)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray3, lineWidth: 1))
                                .onTapGesture {
                                    openURL(URL(string: pullRequest.url)!)
                                }
                        }
                    }
                }
                
                
                ForEach(watchedUserViewModel.prList, id: \.0) { (name, prList) in
                    if let filteredPRList = prList.filter(filterViewModel.combinedFilter?.filter ?? { _ in true }), !filteredPRList.isEmpty {
                        
                        Section(header: Rectangle().frame(height: 45).foregroundColor(.gray5).overlay(Text(name).font(.title).bold().padding(.leading), alignment: .leading)) {
                            ForEach(filteredPRList, id: \.id) { pullRequest in
                                PullRequestCell(pullRequest: pullRequest)
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray3, lineWidth: 1))
                                    .onTapGesture {
                                        openURL(URL(string: pullRequest.url)!)
                                    }
                            }
                        }
                    }
                    
                }
            }
            .padding()
            .onAppear {
                prListViewModel.getPRList()
                watchedUserViewModel.getPRList()
            }
            .onChange(of: prListViewModel.additionalFilters, perform: updateAdditionalFilters(_:))
            .onChange(of: watchedUserViewModel.additionalFilters, perform: updateAdditionalFilters(_:))
        }
    }
    
    private func updateAdditionalFilters(_ filters: [String: [Filter]]?) {
        if let labelSection = filterViewModel.sections.first(where: { $0.name == "Labels" }) {
            let combinedFilters = labelSection.filters + (filters?["Labels"] ?? [])
            labelSection.filters = combinedFilters.arrayByRemovingDuplicates().sorted { $0.name < $1.name }
        }
        
        if let repositorySection = filterViewModel.sections.first(where: { $0.name == "Repository" }) {
            let combinedFilters = repositorySection.filters + (filters?["Repository"] ?? [])
            repositorySection.filters = combinedFilters.arrayByRemovingDuplicates().sorted { $0.name < $1.name }
        }
    }
}

struct PRListView_Previews: PreviewProvider {
    static var previews: some View {
        PRListView()
    }
}
