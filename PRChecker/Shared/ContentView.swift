//
//  ContentView.swift
//  Shared
//
//  Created by Bruce Evans on 2021/11/02.
//

import SwiftUI

struct ContentView: View {
    @State var showLogin = true
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
                    .buttonStyle(.link)
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
                        .buttonStyle(.link)
                }
                .frame(alignment: .leading)
                .border(BackgroundStyle(), width: 5.0)
                Spacer()
                Text("Hello, world!")
                Spacer()
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
