//
//  PullRequestCell.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct PullRequestCell: View {
    
    @StateObject var pullRequest: PullRequest
    
    var body: some View {
        VStack(alignment: .leading) {
            Header(header: pullRequest.headerViewModel)
                .padding(8)
            Divider()
            ContentBody(content: pullRequest.contentViewModel)
                .padding(8)
            Divider()
            Footer(footer: pullRequest.footerViewModel)
                .padding(8)
        }
        .frame(minWidth: 300, maxWidth: 300)
        .background(Color.gray6)
    }
}

// MARK: - Title

private struct Header: View {
    
    @State var header: PullRequest.Header
    
    var body: some View {
        VStack(alignment: .leading) {
            // Repository Name
            HStack(alignment: .top) {
                Text(header.repoName)
                    .padding(8)
                    .font(.headline)
                    .background(Color.gray5)
                    .cornerRadius(8)
            }
            .padding(.vertical, 4)

            // Title, Status
            HStack(alignment: .top) {
                Text(header.status.rawValue)
                    .padding(4)
                    .foregroundColor(.white)
                    .background(header.status.color)
                    .font(.subheadline)
                    .cornerRadius(8)
                // TODO: combine title and number
                Text(header.title)
                    .font(.title2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
                .frame(height: 6)

            // Branch
            HStack {
                Image(systemName: "arrow.triangle.branch")
                    .scaledToFit()
                    .foregroundColor(.green)
                BranchLabel(
                    labelText: header.targetBranch,
                    type: .origin
                )
                Image(systemName: "arrow.backward")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                BranchLabel(
                    labelText: header.headBranch,
                    type: .new
                )
            }
        }
    }
}

enum BranchType {
    case origin
    case new

    var color: Color {
        switch self {
        case .origin:
            return .init(red: 0.8, green: 0.9, blue: 0.8)
        case .new:
            return .init(red: 0.7, green: 0.9, blue: 0.9)
        }
    }
}

private struct BranchLabel: View {
    let labelText: String
    let type: BranchType

    var body: some View {
        Tag(text: labelText, color: type.color)
    }
}

// MARK: - Body

private struct ContentBody: View {
    
    @State var content: PullRequest.Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User
            HStack(alignment: .top) {
                Image(systemName: "person")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                Text(content.author)
                    .font(.caption)
            }

            // Line Additions/Deletions, Commit count
            HStack(alignment: .top) {
                Image(systemName: "plus.slash.minus")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                HStack {
                    Text(content.additions)
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(content.deletions)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                HStack {
                    Image(systemName: "number.square")
                        .scaledToFit()
                        .foregroundColor(Color.primary)
                    Text(content.commits)
                        .font(.caption)
                }
                .padding(.leading, 16)
            }

            // Description
            HStack(alignment: .top) {
                Image(systemName: "doc.text")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                Text(content.description)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(8)
                    .background(Color.gray5)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
                    .cornerRadius(8)
            }

            // Tags
            HStack {
                Image(systemName: "tag")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                ForEach(content.labels, id: \.id) { label in
                    Tag(text: label.title, color: label.color)
                }
            }
        }
    }
}

private struct Tag: View {
    let text: String
    let color: Color

    var body: some View {
        HStack {
            Text(text)
                .padding(4)
                .foregroundColor(.black)
                .background(color)
                .font(.caption)
                .cornerRadius(8)
        }
    }
}

// MARK: - Footer

private struct Footer: View {
    
    @State var footer: PullRequest.Footer
    
    var body: some View {
        VStack {
            // Viewer Status
            HStack {
                Image(systemName: "command")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                Tag(text: footer.status.rawValue, color: footer.status.color)
                Spacer()
                // TODO: Fix timestamp
                Text(footer.createdTime)
                    .padding(.horizontal, 8)
                    .font(.caption)
            }
        }
    }
}

struct PullRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PullRequestCell(pullRequest: PullRequest(pullRequest: PrInfo(id: "1", isReadByViewer: false, url: "https://google.com", repository: .init(id: "2", nameWithOwner: "testUser/testRepo"), baseRefName: "main", headRefName: "dev", author: .makeBot(login: "testBot"), title: "Test PR title", body: "Test PR Body", changedFiles: 3, additions: 4, deletions: 5, commits: .init(nodes: [.init(id: "6")]), labels: .init(nodes: .none), state: .open, viewerLatestReview: nil, mergedAt: "2021", createdAt: "2021"))).preferredColorScheme($0)
        }
    }
}
