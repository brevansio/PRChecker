//
//  PullRequestCell.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct PullRequestCell: View {
    var body: some View {
        VStack(alignment: .leading) {
            Header()
                .padding(8)
            Divider()
            ContentBody()
                .padding(8)
            Divider()
            Footer()
                .padding(8)
        }
        .frame(minWidth: 300, maxWidth: .infinity)
        .background(Color.gray6)
    }
}

// MARK: - Title

private struct Header: View {
    var body: some View {
        VStack(alignment: .leading) {
            // Repository Name
            HStack(alignment: .top) {
                Text("xxxxxxxx/PRChecker")
                    .padding(8)
                    .font(.headline)
                    .background(Color.gray5)
                    .cornerRadius(8)
            }
            .padding(.vertical, 4)

            // Title, Status
            HStack(alignment: .top) {
                Text("Open")
                    .padding(4)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .font(.subheadline)
                    .cornerRadius(8)
                // TODO: combine title and number
                Text("Setup the basic API and Project #1")
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
                    labelText: "origin",
                    type: .origin
                )
                Image(systemName: "arrow.backward")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                BranchLabel(
                    labelText: "branch-1",
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
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User
            HStack(alignment: .top) {
                Image(systemName: "person")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                Text("User-1234567")
                    .font(.caption)
            }

            // Line Additions/Deletions, Commit count
            HStack(alignment: .top) {
                Image(systemName: "plus.slash.minus")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                HStack {
                    Text("+1,203")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("-87")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                HStack {
                    Image(systemName: "number.square")
                        .scaledToFit()
                        .foregroundColor(Color.primary)
                    Text("9 commits")
                        .font(.caption)
                }
                .padding(.leading, 16)
            }

            // Description
            HStack(alignment: .top) {
                Image(systemName: "doc.text")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                Text("This sets up the project and a basic GraphQL API for grabbing a list of PRs for a user.")
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
                Tag(text: "Feature", color: .yellow)
                Tag(text: "Bugfix", color: .gray)
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
    var body: some View {
        VStack {
            // Viewer Status
            HStack {
                Image(systemName: "command")
                    .scaledToFit()
                    .foregroundColor(Color.primary)
                Tag(text: "Commented", color: .orange)
                Spacer()
                Text("14h")
                    .padding(.horizontal, 8)
                    .font(.caption)
            }
        }
    }
}

struct PullRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            PullRequestCell().preferredColorScheme($0)
        }
    }
}
