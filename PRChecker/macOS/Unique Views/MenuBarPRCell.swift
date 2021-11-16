//
//  MenuBarPRCell.swift
//  PRChecker (macOS)
//
//  Created by Chen Yuhan on 2021/11/07.
//

import SwiftUI

struct MenuBarPRCell: View {

    @State private var isHover = false

    let pullRequest: AbstractPullRequest

    var body: some View {
        VStack(alignment: .leading) {
            // Viewer Status
            Label {
                Tag(
                    text: pullRequest.viewerStatus.rawValue,
                    foregroundColor: .white,
                    backgroundColor: pullRequest.viewerStatus.color
                )
                Spacer()
                Text(pullRequest.updatedAt)
            } icon: {
                PRItemType.viewerStatus.image
            }

            Divider()
                .background(Color.gray5)

            // [Repository Name] Title
            Text("[\(pullRequest.repositoryName)] \(pullRequest.title)")
                .lineLimit(2)
                .truncationMode(.tail)
                .font(.headline)
                .padding(.vertical, 4)
                .frame(alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)


            HStack(alignment: .center) {
                PRItemLabel(text: pullRequest.author, type: .author)

                Label {
                    Tag(
                        text: pullRequest.state.rawValue,
                        foregroundColor: .white,
                        backgroundColor: pullRequest.state.color
                    )
                } icon: {
                    PRItemType.state.image
                }
                .font(.body)
                .padding(.leading, 16)
            }
        }
        .padding()
        .background(isHover ? Color.gray5 : Color.primaryBackground)
        .animation(.spring(), value: isHover)
        .onHover { isHover in
            self.isHover = isHover
        }
    }
}

struct MenuBarPRCell_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            MenuBarPRCell(pullRequest: PullRequest(pullRequest: PrInfo(id: "1", isReadByViewer: false, url: "https://google.com", repository: .init(id: "2", nameWithOwner: "testUser/testRepo"), baseRefName: "main", headRefName: "dev", author: .makeBot(login: "testBot"), title: "Test PR title", body: "Test PR Body", changedFiles: 3, additions: 4, deletions: 5, commits: .init(nodes: [.init(id: "6")]), labels: .init(nodes: .none), state: .open, viewerLatestReview: nil, mergedAt: "2021", updatedAt: "2021"), currentUser: "test")).preferredColorScheme($0)
        }
    }
}
