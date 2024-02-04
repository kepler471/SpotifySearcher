//
//  SpotifySearcherApp.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 12/01/2024.
//

import SwiftUI
import HotKey
import MenuBarExtraAccess

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

@main
struct SpotifySearcherApp: App {
    @StateObject var auth = Auth()
    @StateObject var player = Player()
    @State private var showingDetail = false
    @State var isMenuPresented: Bool = false

//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let hotkey = HotKey(key: .s, modifiers: [.command, .control])
    
    var body: some Scene {
        Window("Home", id: "home") {
            PlaceholderView()
                .environmentObject(auth)
                .environmentObject(player)
                .onAppear {
                    player.auth = auth
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { NSApplication.shared.keyWindow?.close() }
                    hotkey.keyDownHandler = {
                        if isMenuPresented {
                            player.stopTimer()
                        } else {
                            player.startTimer()
//                            player.update()
                        }
                        isMenuPresented.toggle()
                    }
                }
                .onOpenURL { url in // TODO: Move within ContentView
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
        
        MenuBarExtra("SpotifySearcher", systemImage: "music.note.list") {
            ContentView()
                .environmentObject(auth)
                .environmentObject(player)
                .onAppear { player.auth = auth }
                .frame(width: 600, height: 600)
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented)
        .defaultPosition(.topLeading)
    }
}
