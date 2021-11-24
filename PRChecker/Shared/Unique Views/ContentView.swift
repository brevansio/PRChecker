//
//  ContentView.swift
//  Shared
//
//  Created by Bruce Evans on 2021/11/02.
//

import SwiftUI

struct ContentView: View {
    @State var showLogin = !SettingsViewModel.shared.loginViewModel.canLogin
    @State var showSettings = false
    var prListViewModel = PRListViewModel()
    
    var body: some View {
        NavigationView {
            // Side bar
            FilterView()
                .frame(minWidth: 300)
            // PR List
            GeometryReader { geometry in
                PRListView(prListViewModel: prListViewModel)
                    .frame(
                        minWidth: 300,
                        maxWidth: max(geometry.size.width, 300),
                        minHeight: geometry.size.height,
                        alignment: .topLeading
                    )
            }
            .overlay(
                HStack {
                    VStack {
                        Spacer()
                        
                        Button {
                            showSettings.toggle()
                        } label: {
                            Text(.init(systemName: "gearshape"))
                                .font(.system(size: 45))
                                .fontWeight(.thin)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(LinkButtonStyle())
                        .popover(isPresented: $showSettings, arrowEdge: .bottom) {
                            SettingsView()
                                .frame(minWidth: 200, maxHeight: 800, alignment: .leading)
                                .onDisappear { prListViewModel.getPRList() }
                        }
                        .padding(8)
                        .background(Color.gray4.clipShape(Circle()))
                    }
                    .padding([.leading, .bottom])
                    
                    Spacer()
                }
            )
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }
    
    private func toggleSidebar() {
        #if canImport(AppKit)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
