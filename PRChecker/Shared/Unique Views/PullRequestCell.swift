//
//  PullRequestCell.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct PullRequestCell: View {
    
    let pullRequest: AbstractPullRequest

    @State private var isHover = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Header(header: pullRequest.headerViewModel, isHover: self.$isHover)
                .padding(EdgeInsets(top: 16, leading: 8, bottom: 8, trailing: 8))
            Divider()
                .background(Color.gray5)
            ContentBody(content: pullRequest.contentViewModel, isHover: self.$isHover)
                .padding(8)
            Divider()
                .background(Color.gray5)
            Footer(footer: pullRequest.footerViewModel)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8))
        }
        .frame(minWidth: 300, maxWidth: 300)
        .background(isHover ? Color.gray5 : Color.primaryBackground)
        .animation(.spring(), value: isHover)
        .onHover { isHover in
            self.isHover = isHover
        }
    }
}

// MARK: - Title

private struct Header: View {
    
    let header: HeaderViewModel

    @Binding var isHover: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            // Repository Name
            HStack(alignment: .top) {
                Text(header.repoName)
                    .padding(8)
                    .font(.headline)
                    .background(isHover ? Color.gray4 : Color.gray5)
                    .cornerRadius(8)
            }
            .padding(.vertical, 4)

            // Title, State
            HStack(alignment: .center) {
                TagView(
                    text: header.status.rawValue,
                    foregroundColor: .white,
                    backgroundColor: header.status.color
                )
                    .font(.subheadline)
                // TODO: combine title and number
                Text(header.title)
                    .font(.title2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
                .frame(height: 6)

            // Branch
            HStack {
                PRItemType.branch.image
                    .scaledToFit()
                    .foregroundColor(.green)
                BranchLabel(
                    labelText: header.targetBranch,
                    type: .origin
                )
                PRItemType.backwardArrow.image
                    .scaledToFit()
                    .foregroundColor(.primary)
                BranchLabel(
                    labelText: header.headBranch,
                    type: .new
                )
            }
        }
    }
}

private struct BranchLabel: View {
    let labelText: String
    let type: BranchType

    var body: some View {
        TagView(
            text: labelText,
            backgroundColor: type.color
        )
    }
}

// MARK: - Body

private struct ContentBody: View {

    let content: ContentViewModel

    @Binding var isHover: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User
            PRItemLabel(text: content.author, type: .author)

            // Line Additions/Deletions, Commit count
            HStack(alignment: .top) {
                Label {
                    HStack {
                        Text(content.additions)
                            .foregroundColor(.green)
                        Text(content.deletions)
                            .foregroundColor(.red)
                    }
                } icon: {
                    PRItemType.changes.image
                }
                .labelStyle(PRItemLabel.Style(type: .changes))

                PRItemLabel(text: content.commits, type: .commits)
                    .padding(.leading, 16)
            }

            // Description
            Label {
                Text(content.description)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .padding(8)
                    .background(isHover ? Color.gray4 : Color.gray5)
                    .fixedSize(horizontal: false, vertical: true)
                    .cornerRadius(8)
            } icon: {
                PRItemType.description.image
            }
            .labelStyle(PRItemLabel.Style(type: .description))

            // Tags
            if !content.labels.isEmpty {
                HStack {
                    PRItemType.tag.image
                        .scaledToFit()
                        .foregroundColor(.green)
                    TagGridView(
                        tagViews: content.labels.map {
                            TagView(text: $0.title, backgroundColor: $0.color)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Footer

private struct Footer: View {
    
    let footer: FooterViewModel
    
    var body: some View {
        VStack {
            // Viewer Status
            Label {
                TagView(
                    text: footer.status.rawValue,
                    foregroundColor: .white,
                    backgroundColor: footer.status.color
                )
                Spacer()
                // TODO: Fix timestamp
                Text(footer.updatedTime)
                    .padding(.horizontal, 8)
            } icon: {
                PRItemType.viewerStatus.image
            }
            .labelStyle(PRItemLabel.Style(type: .viewerStatus))
        }
    }
}

struct PullRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PullRequestCell(pullRequest: PullRequest(pullRequest: PrInfo(id: "1", isReadByViewer: false, url: "https://google.com", repository: .init(id: "2", nameWithOwner: "testUser/testRepo"), baseRefName: "main", headRefName: "dev", author: .makeBot(login: "testBot"), title: "Test PR title", body: "Test PR Body", changedFiles: 3, additions: 4, deletions: 5, commits: .init(nodes: [.init(id: "6")]), labels: .init(nodes: .none), state: .open, viewerLatestReview: nil, mergedAt: "2021", updatedAt: "2021"), currentUser: "test")).preferredColorScheme($0)
        }
    }
}
