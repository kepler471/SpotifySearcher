//
//  SpotifySearcherApp.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 12/01/2024.
//

import SwiftUI
import HotKey
import MenuBarExtraAccess

/// Initial view shown at application startup
struct PlaceholderView: View {
    // This should be a login view. appears on startup
    // Should show a spinner when auth stuff is happening.
    // If connected to a profile, show the user's image and say "welcome \(name)!"
    // Should auto disappear if successfully logged in.
    var body: some View {
        Text("PLACEHOLDER_LOGIN_SCREEN").padding()
        Text("Will auto-close in 10 seconds.").padding()
        Text("Use Command + Control + S to open/close the app (wait for this window to close).").padding()
        Text("FUTURE: This will show login/auth information, and Spotify device selection.").padding()
    }
}

/// Main application entry point for SpotifySearcher
///
/// This is the root of the app that:
/// 1. Initializes authentication and player services
/// 2. Handles OAuth redirect URLs and token exchange
/// 3. Configures the app as a menu bar extra with a global hotkey
/// 4. Provides the main content view with all required environment objects
@main
struct SpotifySearcherApp: App {
    /// Authentication manager for Spotify API access
    @StateObject var auth = Auth()
    
    /// Player controller for Spotify playback
    @StateObject var player = Player()
    
    /// Whether detail view is showing
    @State private var showingDetail = false
    
    /// Whether the menu bar extra is currently presented
    @State var isMenuPresented: Bool = false

    /// Global hotkey to toggle the app visibility (Cmd+Ctrl+S)
    let hotkey = HotKey(key: .s, modifiers: [.command, .control])
    
    var body: some Scene {
        // Initial window that handles authentication
        Window("Home", id: "home") {
            PlaceholderView()
                .environmentObject(auth)
                .environmentObject(player)
                .onAppear {
                    player.auth = auth
                    // Auto-close after 10 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { NSApplication.shared.mainWindow?.close() }
                    // Set up hotkey handler
                    hotkey.keyDownHandler = {
                        isMenuPresented.toggle()
                    }
                }
                .onOpenURL { url in
                    // TODO: remove from this scope
                    if let code = auth.handleRedirectURL(url: url) {
                        auth.exchangeCode(code: code, clientId: auth.clientID, clientSecret: auth.clientSecret, redirectUri: auth.redirectURI) { result in
                            switch result {
                            case .success(let authResponse):
                                auth.accessToken = authResponse.accessToken
                                auth.refreshToken = authResponse.refreshToken
                                
                                let success = auth.saveToKeychain(token: auth.refreshToken, account: "com.kepler471.SpotifySearcher.refreshtoken")
                                if !success {
                                    print("<<<main>>> Failed to save token")
                                }
                                
                            case .failure(let error):
                                print("<<<main>>> Exchange failure, Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
        }
        
        // Menu bar extra where the main app interface lives
        MenuBarExtra("SpotifySearcher", systemImage: "music.note.list") {
            // TODO: add player timer pause toggle
            if #available(macOS 14.0, *) {
                ContentView()
                    .environmentObject(auth)
                    .environmentObject(player)
                    .onAppear {
                        player.auth = auth
                        player.startTimer()
                    }
                    .frame(width: 800, height: 600)
            } else if #available(macOS 13.0, *) {
                ContentView()
                    .environmentObject(auth)
                    .environmentObject(player)
                    .onAppear {
                        player.auth = auth
                        player.startTimer()
                    }
                    .frame(width: 800, height: 600)
            } else {
                ContentView()
                    .environmentObject(auth)
                    .environmentObject(player)
                    .onAppear {
                        player.auth = auth
                        player.startTimer()
                    }
                    .frame(width: 800, height: 600)
            }
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented)
        .defaultPosition(.topLeading)
    }
}
