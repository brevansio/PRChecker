//
//  SettingsView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import SwiftUI

struct SettingsView: View {
    @State var settingsViewModel = SettingsViewModel()
    
    @State var height: Double = 250
    
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
            .frame(
                minWidth: 200,
                maxWidth: .infinity,
                idealHeight: height,
                maxHeight: height
            )
            .onChange(of: settingsViewModel.userList) { newValue in
                height = newValue.isEmpty ? 0 : 250
            }
            
            Spacer()
            HStack {
                TextField(LocalizedStringKey("Username"), text: $settingsViewModel.newUsername)
                Button("Add") {
                    settingsViewModel.addUser()
                }
            }
            .padding([.leading, .trailing])
        }
        .padding(20)
        .frame(minWidth: 200, minHeight: height, maxHeight: 400, alignment: .leading)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
