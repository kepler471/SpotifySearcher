//
//  MenuBarView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 31/01/2024.
//

import SwiftUI
import CommonCrypto
//import Cocoa
import HotKey


struct MenuBarView: View {
    @StateObject private var auth = Auth()
    @StateObject private var player = Player()
    
    let hotkey = HotKey(key: .c, modifiers: [.command, .control])
    
    let globalKeyHandler: () -> Void
    
    init(globalKeyHandler: @escaping () -> Void) {
        self.globalKeyHandler = globalKeyHandler
    }
    
    var body: some View {
        ContentView()
            .frame(width: 600, height: 600)
            .environmentObject(auth)
            .environmentObject(player)
            .onAppear {
                player.auth = auth
                hotkey.keyDownHandler = {
                    print("key combo pressed")
                    globalKeyHandler()
                }
            }
            .onOpenURL { url in // TODO: Move within ContentView
                print("Auth URL opened, redirect received")
                print(url)
                
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
}
