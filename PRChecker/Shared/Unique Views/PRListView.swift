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
    
    @StateObject var prListViewModel = PRListViewModel()
    
    var body: some View {
        RefreshableScrollView(onRefresh: { completion in
            prListViewModel.getPRList() {
                completion()
            }
        }) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], alignment: .leading) {
                ForEach(prListViewModel.prList.filter(filterViewModel.combinedFilter?.filter ?? { _ in true }), id: \.id) { pullRequest in
                    PullRequestCell(pullRequest: pullRequest)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray3, lineWidth: 1))
                        .onTapGesture {
                            openURL(URL(string: pullRequest.url)!)
                        }
                }
            }
            .padding()
            .onAppear {
                prListViewModel.getPRList()
            }
            .onChange(of: prListViewModel.additionalFilters) { newValue in
                if let labelSection = filterViewModel.sections.first(where: { $0.name == "Labels" }) {
                    labelSection.filters = newValue?["Labels"] ?? []
                }
                
                if let repositorySection = filterViewModel.sections.first(where: { $0.name == "Repository" }) {
                    repositorySection.filters = newValue?["Repository"] ?? []
                }
            }
        }
    }
}

struct PRListView_Previews: PreviewProvider {
    static var previews: some View {
        PRListView()
    }
}
