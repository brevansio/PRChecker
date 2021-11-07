//
//  MenuBarPRCell.swift
//  PRChecker (macOS)
//
//  Created by Chen Yuhan on 2021/11/07.
//

import SwiftUI

struct MenuBarPRCell: View {

    let pullRequest: PullRequest

    var body: some View {
        VStack {
            // [Repository Name] Title
            Text("[\(pullRequest.repositoryName)] \(pullRequest.title)")
                .lineLimit(2)
                .padding(4)
                .font(.headline)
                .padding(.vertical, 4)
        }
    }
}

struct MenuBarPRCell_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            MenuBarPRCell(pullRequest: PullRequest(pullRequest: PrInfo(id: "1", isReadByViewer: false, url: "https://google.com", repository: .init(id: "2", nameWithOwner: "testUser/testRepo"), baseRefName: "main", headRefName: "dev", author: .makeBot(login: "testBot"), title: "Test PR title", body: "Test PR Body", changedFiles: 3, additions: 4, deletions: 5, commits: .init(nodes: [.init(id: "6")]), labels: .init(nodes: .none), state: .open, viewerLatestReview: nil, mergedAt: "2021", updatedAt: "2021"))).preferredColorScheme($0)
        }
    }
}
