//
//  PlayPauseButtonView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

struct PlayPauseButtonView: View {
    @EnvironmentObject var player: Player
    
    var body: some View {
        Button {
            player.togglePlaying()
        } label: {
            player.isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
        }
    }
}

#Preview {
    PlayPauseButtonView()
}
