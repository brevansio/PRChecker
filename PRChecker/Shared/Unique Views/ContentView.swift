//
//  ContentView.swift
//  Shared
//
//  Created by Bruce Evans on 2021/11/02.
//

import SwiftUI

struct ContentView: View {
    @State var showLogin = !LoginInfoViewModel().canLogin
    @State var showSettings = false
    var prListViewModel = PRListViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Divider()
                    .background(Color.gray5)
                PRListView(prListViewModel: prListViewModel)
                    .frame(minWidth: 300, maxWidth: max(geometry.size.width, 300), minHeight: geometry.size.height, alignment: .topLeading)
                Divider()
                    .background(Color.gray5)
                FilterView()
                    .frame(width: 300, height: geometry.size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
