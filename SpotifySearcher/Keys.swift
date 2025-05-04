//
//  Keys.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 30/01/2024.
//

import Cocoa
import SwiftUI

/// Checks if no modifier keys are being pressed during an event
///
/// This function determines whether an NSEvent occurred without any
/// modifier keys (like Command, Shift, Control, etc.) being held down.
/// It's primarily used for keyboard event handling to differentiate
/// between modified and unmodified keypresses.
///
/// - Parameter event: The NSEvent to check for modifier keys
/// - Returns: true if no modifier keys are pressed, false otherwise
func isNoModifierPressed(event: NSEvent) -> Bool {
    // Define a mask that includes all modifier keys you want to check
    let modifierFlags: NSEvent.ModifierFlags = [.shift, .control, .option, .command, .help, .function]

    // Check if none of the modifier keys in the mask are pressed
    return event.modifierFlags.intersection(modifierFlags).isEmpty
}

/// Checks if a key event represents an alphanumeric character
///
/// This function determines whether an NSEvent represents a letter or number
/// key press. It's used to detect when the user is attempting to type text,
/// allowing the app to redirect focus to text input fields appropriately.
///
/// - Parameter event: The NSEvent to check for alphanumeric characters
/// - Returns: true if the key represents a letter or number, false otherwise
func isAlphanumericKey(event: NSEvent) -> Bool {
    guard let characters = event.charactersIgnoringModifiers else {
        return false
    }

    // Check if the string contains only alphanumeric characters
    return characters.allSatisfy { $0.isLetter || $0.isNumber }
}
