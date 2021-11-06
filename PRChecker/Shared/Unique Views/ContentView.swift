//
//  ContentView.swift
//  Shared
//
//  Created by Bruce Evans on 2021/11/02.
//

import SwiftUI

struct ContentView: View {
    @State var showLogin = !LoginInfoViewModel().canLogin
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Spacer()
                    Button {
                        showLogin.toggle()
                    } label: {
                        Text(.init(systemName: "person"))
                            .font(.system(size: 45))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(LinkButtonStyle())
                    .popover(isPresented: $showLogin, arrowEdge: .trailing) {
                        LoginView {
                            // TODO: Refresh
                        }
                    }

                    Button {
                        // TODO: Settings Page
                    } label: {
                        Text(.init(systemName: "gearshape"))
                            .font(.system(size: 45))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(LinkButtonStyle())
                }
                .padding([.leading, .bottom, .top])
                Divider()
                PRListView()
                    .frame(minWidth: 300, maxWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
                Divider()
                FilterView()
                    .frame(width: 300, height: geometry.size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
