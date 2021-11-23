//
//  RefreshSettingsView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/14.
//

import SwiftUI

struct RefreshSettingsView: View {
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        HStack {
            Picker(LocalizedStringKey("Refresh Interval"), selection: $settingsViewModel.refreshInterval) {
                ForEach(RefreshSetting.allCases, id: \.rawValue) { setting in
                    Text(LocalizedStringKey(setting.displayString)).tag(setting)
                }
            }
        }
    }
}

struct RefreshSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshSettingsView(settingsViewModel: SettingsViewModel.shared)
    }
}

extension RefreshSetting {    
    var displayString: String {
        switch self {
        case .fiveMinutes:
            return "5 min"
        case .tenMinutes:
            return "10 min"
        case .fifteenMinutes:
            return "15 min"
        case .thirtyMinutes:
            return "30 min"
        case .oneHour:
            return "60 min"
        case .never:
            return "Never"
        }
    }
}
