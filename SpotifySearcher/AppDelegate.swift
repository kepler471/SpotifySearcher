//
//  AppDelegate.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 30/01/2024.


import Cocoa
import SwiftUI
import Carbon

//let key: CGKeyCode = 0x6F  // Example: 'Pause/Play media' key
let key: CGKeyCode = 0x04  // Example: 'H' key
let modifierFlags: CGEventFlags = .maskCommand  // Example: Command key as the modifier

func globalEventTapCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if type == .keyDown {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        if keyCode == Int64(key) && flags.contains(modifierFlags) {
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                print("key combo pressed")
                // Implement additional logic to open or focus on your MenuBarExtra app
            }
            return nil
        }
    }
    return Unmanaged.passRetained(event)
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var eventTap: CFMachPort?
    
    var popover = NSPopover.init()
    var statusBarItem: NSStatusItem?

    override init() {
        super.init()
        // Create the SwiftUI view that provides the contents
        let contentView = ContentView()

        // Set the SwiftUI's view to the popover's content view
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)

        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "music.note.list", accessibilityDescription: nil)
            button.action = #selector(togglePopover(_:))
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: globalEventTapCallback,
            userInfo: nil
        )

        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        } else {
            print("Failed to create event tap")
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                if let button = statusBarItem?.button {
                    NSApp.activate(ignoringOtherApps: true)
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }
        }

    @objc func showAppFromMenuBar() {
        NSApp.activate(ignoringOtherApps: true)
        if let button = statusBarItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
}
