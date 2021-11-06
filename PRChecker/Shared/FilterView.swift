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
                .padding(8)
            Spacer()
        }
    }
}

private struct Header: View {
    var body: some View {
        HStack {
            Label {
                Text("Filter")
                    .font(.title)
            } icon: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .scaledToFit()
            }
            Spacer()
            Button(action: {
                // TODO:
            }) {
                HStack {
                    Text("Clear")
                    Image(systemName: "xmark.circle")
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}


