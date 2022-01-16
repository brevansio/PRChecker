//
//  MenuView.swift
//  PRChecker (macOS)
//
//  Created by Chen Yuhan on 2021/11/07.
//

import SwiftUI

struct MenuView: View {

    @Environment(\.openURL) var openURL

    @StateObject var prListViewModel = PRListViewModel()

    @ObservedObject var myPRManager = MyPRManager.shared
    
    private let maxPRCount = 5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(myPRManager.prList.prefix(maxPRCount)) { pullRequest in
                    MenuBarPRCell(pullRequest: pullRequest)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray3, lineWidth: 1)
                        )
                        .padding(.horizontal, 12)
                        .onTapGesture {
                            openURL(URL(string: pullRequest.url)!)
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .background(Color.gray6)
        .onAppear {
            prListViewModel.getMyPRList()
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
