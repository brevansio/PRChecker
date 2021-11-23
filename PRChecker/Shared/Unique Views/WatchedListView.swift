//
//  WatchedListView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/14.
//

import Foundation
import SwiftUI

struct WatchedListView: View {
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        List {
            ForEach(settingsViewModel.userList, id: \.self) { user in
                WatchedUserView(username: user) { settingsViewModel.remove($0) }
            }
            .onDelete { indexSet in
                settingsViewModel.remove(indexSet)
            }
        }
        .frame(height: 300)
        
        Spacer()
        AddUserView() { settingsViewModel.addUser($0) }
        .padding([.leading, .trailing])
    }
}

struct WatchedUserView: View {
    var username: String
    var onRemove: ((String) -> Void)?
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .font(.title)
            Text(username)
                .font(.title)
            Spacer()
            Button {
                onRemove?(username)
            } label: {
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding([.leading, .trailing, .top])
    }
}

struct AddUserView: View {
    @State var newUsername = ""
    var onAdd: ((String) -> Void)?
    
    var body: some View {
        HStack {
            TextField(LocalizedStringKey("Username"), text: $newUsername)
            Button("Add") {
                guard !newUsername.isEmpty else { return }
                onAdd?(newUsername)
                newUsername = ""
            }
        }
    }
}
