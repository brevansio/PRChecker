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
    @State var refreshable = true
    
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
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                        .renderingMode(.template)
                        .foregroundColor(Color.primary)
                })
            }
            ToolbarItem(placement: .primaryAction) {
                if refreshable {
                    Button {
                        refreshable = false
                        prListViewModel.getPRList() { refreshable = true }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .renderingMode(.template)
                            .foregroundColor(Color.primary)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.75)
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gearshape")
                        .renderingMode(.template)
                        .foregroundColor(Color.primary)
                }
                .popover(isPresented: $showSettings) {
                    SettingsView()
                        .frame(minWidth: 200, maxHeight: 800, alignment: .leading)
                        .onDisappear { prListViewModel.getPRList() }
                }
            }
        }
    }
    
    private func toggleSidebar() {
        #if canImport(AppKit)
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil
        )
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
