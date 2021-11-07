//
//  MenuController.swift
//  PRChecker (macOS)
//
//  Created by Chen Yuhan on 2021/11/07.
//

import AppKit
import SwiftUI

class MenuController {

    private let popover: NSPopover
    private let statusItem: NSStatusItem?

    init(statusItem: NSStatusItem?) {
        self.statusItem = statusItem
        self.popover = NSPopover()

        let menuView = MenuView()

        popover.contentViewController = NSHostingController(rootView: menuView)
        popover.contentSize = NSSize(width: 300, height: 400)

        popover.behavior = .transient
        popover.animates = true
    }

    @objc func didTapMenuButton(_ sender: AnyObject) {
        guard let statusItemButton = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        }
        else {
            popover.show(
                relativeTo: statusItemButton.bounds,
                of: statusItemButton,
                preferredEdge: .maxY
            )
        }
    }
}
