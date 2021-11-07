//
//  MenuController.swift
//  PRChecker (macOS)
//
//  Created by Chen Yuhan on 2021/11/07.
//

import AppKit
import SwiftUI

class MenuController {

    private let popover = NSPopover()

    init() {
        let menuView = MenuView()

        popover.contentViewController = NSHostingController(rootView: menuView)
        popover.contentSize = NSSize(width: 320, height: 400)

        popover.behavior = .transient
        popover.animates = true
    }

    @objc func didTapMenuButton(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        }
        else {
            popover.show(
                relativeTo: sender.bounds,
                of: sender,
                preferredEdge: .maxY
            )

            // Focus on the popover when it's clicked
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
