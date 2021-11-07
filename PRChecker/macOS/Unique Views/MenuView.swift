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
    
    private let maxPRCount = 5

    var body: some View {
        List(prListViewModel.prList.prefix(maxPRCount)) { pullRequest in
            MenuBarPRCell(pullRequest: pullRequest)
                .onTapGesture {
                    openURL(URL(string: pullRequest.url)!)
                }
        }
        .onAppear {
            prListViewModel.getPRList()
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
