//
//  PRListView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import SwiftUI

struct PRListView: View {
    @Environment(\.openURL) var openURL
    
    @StateObject var prListViewModel = PRListViewModel()
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 300)), GridItem(.flexible(minimum: 300))], alignment: .leading) {
            ForEach(prListViewModel.prList, id: \.id) { pullRequest in
                PullRequestCell(pullRequest: pullRequest)
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.secondary, lineWidth: 1))
                    .onTapGesture {
                        openURL(URL(string: pullRequest.url)!)
                    }
            }
        }
        .padding()
        .onAppear {
            prListViewModel.getPRList()
        }
    }
}

struct PRListView_Previews: PreviewProvider {
    static var previews: some View {
        PRListView()
    }
}
