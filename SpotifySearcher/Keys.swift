//
//  Keys.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 30/01/2024.
//

import Cocoa
import SwiftUI

func isNoModifierPressed(event: NSEvent) -> Bool {
    // Define a mask that includes all modifier keys you want to check
    let modifierFlags: NSEvent.ModifierFlags = [.shift, .control, .option, .command, .help, .function]

    // Check if none of the modifier keys in the mask are pressed
    return event.modifierFlags.intersection(modifierFlags).isEmpty
}

func isAlphanumericKey(event: NSEvent) -> Bool {
    guard let characters = event.charactersIgnoringModifiers else {
        return false
    }

    // Check if the string contains only alphanumeric characters
    return characters.allSatisfy { $0.isLetter || $0.isNumber }
}

class KeyPressResponder: NSResponder {
    var key: KeyEquivalent
    var action: () -> Void

    init(key: KeyEquivalent, action: @escaping () -> Void) {
        self.key = key
        self.action = action
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(key.character) {
            action()
        } else {
            super.keyDown(with: event)
        }
    }
}

struct OnKeyPressModifier: ViewModifier {
    var key: KeyEquivalent
    var action: () -> Void

    func body(content: Content) -> some View {
        content.background(OnKeyPressHandlingView(key: key, action: action))
    }
}

struct OnKeyPressHandlingView: NSViewRepresentable {
    var key: KeyEquivalent
    var action: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let keyPressResponder = KeyPressResponder(key: key, action: action)
        view.addResponder(keyPressResponder)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension NSView {
    func addResponder(_ responder: NSResponder) {
        if let currentResponder = nextResponder {
            nextResponder = responder
            responder.nextResponder = currentResponder
        }
    }
}

extension View {
    func myKeyPress(_ key: KeyEquivalent, action: @escaping () -> Void) -> some View {
        self.modifier(OnKeyPressModifier(key: key, action: action))
    }
}
