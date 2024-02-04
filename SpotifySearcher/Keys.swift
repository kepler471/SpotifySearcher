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
