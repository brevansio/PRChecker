//
//  LoginView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/06.
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct LoginView: View {
    private let helpURL =
        URL(string: "https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token")!
    @State private var loginInfo = LoginInfoViewModel()
        
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                TextField(LocalizedStringKey("Username"), text: $loginInfo.username)
                HStack {
                    TextField(LocalizedStringKey("Access Token"), text: $loginInfo.accessToken)
                    Group {
                        VStack {
                            Link(destination: helpURL, label: {
                                Image(systemName: "questionmark.circle")
                            })
                                .foregroundColor(.secondary)
                                .padding(5)
                        }
                    }
                }
                TextField(LocalizedStringKey("API Endpoint"), text: $loginInfo.apiEndpoint)
                Toggle(isOn: $loginInfo.useLegacyQuery) {
                    Text("Use Legacy Queries")
                }
                // TODO: Some sort of guidance on the legacy query usage
            }
        }
        .padding(20)
        .onDisappear {
            loginInfo.saveToKeychain()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
