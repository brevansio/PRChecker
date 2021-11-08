//
//  AppDelegate.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/07.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var menuController: MenuController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: 16)

        guard let statusItemButton = statusItem?.button else { return }

        statusItemButton.image = NSImage(
            systemSymbolName: "drop",
            accessibilityDescription: nil
        )
        statusItemButton.image?.size = NSSize(width: 16, height: 16)
        statusItemButton.action = #selector(didTapMenuButton(_:))
        statusItemButton.target = self

        menuController = MenuController()
    }

    @objc private func didTapMenuButton(_ sender: NSStatusBarButton) {
        menuController?.didTapMenuButton(sender)
    }
}
