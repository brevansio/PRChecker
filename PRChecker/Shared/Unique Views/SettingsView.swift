//
//  SettingsView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel = SettingsViewModel.shared
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                LoginView()
                    .frame(maxWidth: 600, maxHeight: 200, alignment: .leading)
                
                Divider()
                
                RefreshSettingsView(settingsViewModel: settingsViewModel)
                
                Divider()
                
                DisplayOptionView(settingsViewModel: settingsViewModel)
                
                Divider()
                
                WatchedListView(settingsViewModel: settingsViewModel)
            }
            .padding()
        }
        .padding(20)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
