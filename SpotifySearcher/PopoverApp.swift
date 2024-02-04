//
//  PopoverApp.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 31/01/2024.
//

import Foundation
import HotKey
import Cocoa
import SwiftUI

//@main
struct PopoverApp: App {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let popover = NSPopover()
    
    let hotkey = HotKey(key: .c, modifiers: [.command, .control])

    init() {
        // Setup the popover
        popover.contentSize = NSSize(width: 600, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView(globalKeyHandler: showPopover))
    }
    
    private func showPopover() {
        if let button = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength).button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    var body: some Scene {
        MenuBarExtra("SpotifySearcher", systemImage: "music.note.list") {
            MenuBarView(globalKeyHandler: showPopover)
        }
        .menuBarExtraStyle(.window)
    }
}
