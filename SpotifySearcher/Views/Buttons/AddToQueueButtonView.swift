//
//  AddToQueueButtonView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

struct AddToQueueButtonView: View {
    @EnvironmentObject var auth: Auth
    let track: Track
    
    var body: some View {
        Button {
            MySpotifyAPI.shared.addToQueue(accessToken: auth.accessToken, trackUri: track.uri) { _ in }
        } label: {
            Image(systemName: "text.badge.plus")
        }
        .keyboardShortcut("a")
    }
}

#Preview {
    AddToQueueButtonView(track: blank0)
}
