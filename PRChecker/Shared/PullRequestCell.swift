//
//  PullRequestCell.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct PullRequestCell: View {
    var body: some View {
        VStack {
            Header()
                .padding(6)
            Divider()
        }
    }
}

// MARK: - Title

private struct Header: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Setup the basic API and Project")
                    .font(.title)
            }
            Spacer()
                .frame(height: 6)
            HStack {
                Image(systemName: "arrow.triangle.branch")
                    .scaledToFit()
                    .foregroundColor(.green)
                Text("User")
                    .font(.subheadline)
                Text("wants to merge 10 commits into")
                    .font(.subheadline)
                BranchLabel(
                    labelText: "origin",
                    type: .origin
                )
                Text("from")
                    .font(.subheadline)
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
        HStack {
            Text(labelText)
                .padding(4)
                .background(type.color)
                .font(.subheadline)
                .cornerRadius(8)
        }
    }
}

// MARK: - Body

struct PullRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        PullRequestCell()
    }
}
