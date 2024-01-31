//
//  SpotifySearcherApp.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 12/01/2024.
//

import SwiftUI
import HotKey

@main
struct SpotifySearcherApp: App {
    @StateObject var auth = Auth()
    @StateObject var player = Player()
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
//    let hotkey = HotKey(key: .f8, modifiers: [.command])

    var body: some Scene {
        WindowGroup() {
            ContentView() // This could be some basic placeholder window, or hidden?
                .environmentObject(auth)
                .environmentObject(player)
                .onAppear {
                    player.auth = auth
//                    hotkey.keyDownHandler = { print("button pressed") }
                }
                .onOpenURL { url in // TODO: Move within ContentView
                    print("Auth URL opened, redirect received")
                    print(url)
                    // TODO: remove from this scope
                    if let code = auth.handleRedirectURL(url: url) {
                        auth.exchangeCode(code: code, clientId: auth.clientID, clientSecret: auth.clientSecret, redirectUri: auth.redirectURI) { result in
                            switch result {
                            case .success(let authResponse):
                                // Handle success
                                print("Exchange success, got Access Token")
                                // Optionally handle the refresh token and other response data
                                //                                respAuth = authResponse
                                auth.accessToken = authResponse.accessToken
                                auth.refreshToken = authResponse.refreshToken
                                
                                let success = auth.saveToKeychain(token: auth.refreshToken, account: "com.kepler471.SpotifySearcher.refreshtoken")
                                if success {
                                    print("Token saved successfully")
                                } else {
                                    print("Failed to save token")
                                }
                                
                                
                            case .failure(let error):
                                // Handle error
                                print("Exchange failure, Error: \(error.localizedDescription)")
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
    }
}
