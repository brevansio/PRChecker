//
//  FilterView.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct FilterView: View {
    var body: some View {
        VStack {
            Header()
                .padding(EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 8))
            Divider()
            FilterContentView()
                .padding(.leading, 8)
            Spacer()
        }
    }
}

private struct Header: View {
    var body: some View {
        HStack {
            Label {
                Text("Filter by")
                    .font(.title)
                    .fontWeight(.bold)
            } icon: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .scaledToFit()
            }
            Spacer()
            Button("Reset Filters") {
                // TODO: action
            }
            .font(.title2)
            .foregroundColor(.blue)
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct FilterContentView: View {
    struct Section: View {
        var body: some View {
            VStack(alignment: .leading) {
                Label {
                    Text("Status")
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "square.stack.3d.down.right")
                        .scaledToFit()
                }
                .font(.title2)

                VStack(spacing: 10) {
                    ForEach(0..<3) { _ in
                        CheckBox(text: "Open")
                    }
                }
                .padding(8)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(0..<10) { _ in
                    Section()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
