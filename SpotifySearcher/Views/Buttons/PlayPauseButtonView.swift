//
//  PlayPauseButtonView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

/// Button to toggle playback between playing and paused states
///
/// This button controls the playback of the current Spotify track, allowing
/// users to pause or resume playback with a single click. The button directly 
/// communicates with the Spotify API through the Player class to control
/// the playback state.
struct PlayPauseButtonView: View {
    /// Access to the player state for playback control
    @EnvironmentObject var player: Player
    
    var body: some View {
        Button {
            player.togglePlaying()
        } label: {
            player.isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
        }
    }
}

#Preview("Play Button") {
    let mockPlayer = PreviewData.MockPlayer()
    mockPlayer.isPlaying = false
    
    return PlayPauseButtonView()
        .environmentObject(mockPlayer as Player)
}

#Preview("Pause Button") {
    let mockPlayer = PreviewData.MockPlayer()
    mockPlayer.isPlaying = true
    
    return PlayPauseButtonView()
        .environmentObject(mockPlayer as Player)
}
