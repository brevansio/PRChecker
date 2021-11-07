//
//  SettingsView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import SwiftUI

struct SettingsView: View {
    @State var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(settingsViewModel.userList, id: \.self) { user in
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.title)
                        Text(user)
                            .font(.title)
                        Spacer()
                        Button {
                            settingsViewModel.remove(user)
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding([.leading, .trailing, .top])
                }
            }
            .frame(minWidth: 200, maxWidth: .infinity, idealHeight: settingsViewModel.userList.isEmpty ? 0 : 250, maxHeight: settingsViewModel.userList.isEmpty ? 0 : 250)
            
            HStack {
                TextField(LocalizedStringKey("Username"), text: $settingsViewModel.newUsername)
                Button("Add") {
                    settingsViewModel.addUser()
                }
            }
            .padding([.leading, .trailing])
        }
        .padding(20)
        .frame(minWidth: 200, maxHeight: 400, alignment: .leading)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
