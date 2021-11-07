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
    
    let dismissBlock: (() -> Void)?
    
    var body: some View {
        HStack {
            VStack {
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
            }
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
        .frame(maxWidth: 400, maxHeight: 200, alignment: .center)
        .onDisappear {
            loginInfo.saveToKeychain()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(dismissBlock: nil)
    }
}
