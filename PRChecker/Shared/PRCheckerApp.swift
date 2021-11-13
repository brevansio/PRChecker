//
//  PRCheckerApp.swift
//  Shared
//
//  Created by Bruce Evans on 2021/11/02.
//

import SwiftUI

@main
struct PRCheckerApp: App {

#if canImport(AppKit)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FilterViewModel())
                .background(Color.gray6)
                .frame(minWidth: 655, minHeight: 375)
        }
    }
}
