//
//  AppDelegate.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/07.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let menuView = MenuView()

        popover.behavior = .transient
        popover.animates = true

        popover.contentViewController = NSHostingController(rootView: menuView)
        popover.contentSize = NSSize(width: 400, height: 500)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let statusItemButton = statusItem?.button else { return }

        statusItemButton.image = NSImage(
            systemSymbolName: "drop",
            accessibilityDescription: nil

        )
        statusItemButton.action = #selector(didTapMenuButton)
    }

    @objc private func didTapMenuButton() {
        guard let statusItemButton = statusItem?.button else { return }

        popover.show(
            relativeTo: statusItemButton.bounds,
            of: statusItemButton,
            preferredEdge: .minY
        )
    }
}
