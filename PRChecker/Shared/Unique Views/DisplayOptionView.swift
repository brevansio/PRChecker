//
//  DisplayOptionView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/14.
//

import SwiftUI

struct DisplayOptionView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @State var showAssigned: Bool
    @State var showReviewRequested: Bool
    @State var showReviewed: Bool
    
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        
        showAssigned = settingsViewModel.displayOptions.contains(.assigned)
        showReviewRequested = settingsViewModel.displayOptions.contains(.reviewRequested)
        showReviewed = settingsViewModel.displayOptions.contains(.reviewed)
    }
    
    var body: some View {
        Text(LocalizedStringKey("Included PRs"))
        HStack {
            Toggle(LocalizedStringKey("Assigned"), isOn: $showAssigned)
                .onChange(of: showAssigned) { newValue in
                    if newValue {
                        settingsViewModel.displayOptions = settingsViewModel.displayOptions.union(.assigned)
                    } else {
                        settingsViewModel.displayOptions = settingsViewModel.displayOptions.subtracting(.assigned)
                    }
                }
            Toggle(LocalizedStringKey("Review Requested"), isOn: $showReviewRequested)
                .onChange(of: showReviewRequested) { newValue in
                    if newValue {
                        settingsViewModel.displayOptions = settingsViewModel.displayOptions.union(.reviewRequested)
                    } else {
                        settingsViewModel.displayOptions = settingsViewModel.displayOptions.subtracting(.reviewRequested)
                    }
                }
            Toggle(LocalizedStringKey("Reviewed"), isOn: $showReviewed)
                .onChange(of: showReviewed) { newValue in
                    if newValue {
                        settingsViewModel.displayOptions = settingsViewModel.displayOptions.union(.reviewed)
                    } else {
                        settingsViewModel.displayOptions = settingsViewModel.displayOptions.subtracting(.reviewed)
                    }
                }
        }
    }
}

struct DisplayOptionView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayOptionView(settingsViewModel: SettingsViewModel.shared)
    }
}
