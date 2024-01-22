//
//  SpotifySearcherApp.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 12/01/2024.
//

import SwiftUI
import CommonCrypto
import Cocoa


@main
struct SpotifySearcherApp: App {
    init() {}
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    print(url)
//                    func handleRedirectURL(url: URL) {
//                        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
//                              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
//                            // Handle error: No code in URL
//                            return
//                        }
//
//                        // Now you have the authorization code
//                        exchangeCodeForToken(code: code)
//                    }
//                    Request an access token here
                }
        }
    }
}
