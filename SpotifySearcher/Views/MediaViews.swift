//
//  MediaViews.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 22/01/2024.
//

import Foundation
import SwiftUI
import AVFoundation

/// Adds an underline to content when hovered
///
/// This modifier provides a visual indication of interactive elements
/// by showing an underline when the user hovers over the content.
struct HoverUnderlineModifier: ViewModifier {
    @State private var isHovering: Bool = false
    
    func body(content: Content) -> some View {
        content
            .underline(isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

/// Displays the currently playing Spotify track
///
/// This view shows information about the currently playing track in the persistent
/// footer area of the app. It includes:
/// - The track artwork, name, artists, and album
/// - Like/unlike button for saving to the user's library
/// - Play/pause button for controlling playback
/// - A placeholder state when no track is playing
struct CurrentTrackView: View {
    @EnvironmentObject var player: Player
    
    var body: some View {
        HStack {
            if let track = player.currentTrack {
                TrackView(track: track, isMarqueeActive: true)
                LikeButtonView()
                PlayPauseButtonView()
            } else {
                Image(systemName: "music.note.list").frame(width: 64, height: 64).font(.title)
                Spacer()
                Text("----------------").font(.title)
                Spacer()
            }
        }
    }
}

#Preview("Current Track View - With Track") {
    let mockPlayer = PreviewData.MockPlayer()
    mockPlayer.currentTrack = PreviewData.track3
    mockPlayer.isPlaying = true
    
    return CurrentTrackView()
        .environmentObject(mockPlayer as Player)
        .environmentObject(PreviewData.MockAuth() as Auth)
}

#Preview("Current Track View - No Track") {
    let mockPlayer = PreviewData.MockPlayer()
    mockPlayer.currentTrack = nil
    
    return CurrentTrackView()
        .environmentObject(mockPlayer as Player)
        .environmentObject(PreviewData.MockAuth() as Auth)
}

/// Provides a 30-second audio preview of a track
///
/// This modal view allows the user to listen to a track's preview audio (if available)
/// without interrupting their current Spotify playback. Features include:
/// - Album artwork display
/// - Volume control slider
/// - Automatic audio playback on appearance
/// - Automatic cleanup on dismissal
///
/// Note: Preview URLs are provided by Spotify and may not be available for all tracks.
struct PreviewView: View {
    @State private var player: AVPlayer?
    @State private var volume: Double = 1.0
    let track: Track
    
    // TODO: Lower Spotify audio when this is playing
    // TODO: Update the slider live (before releasing)
    // TODO: Fix me I'm buggy
    
    var body: some View {
        if let preview_url = track.preview_url {
            AsyncImage(url: URL(string: track.album.images[1].url)!)
            Slider(value: $volume, in: 0...1, step: 0.01) {
                Image(systemName: "volume.2.fill")
            } onEditingChanged: { editing in
                player?.volume = Float(volume)
            }
            .padding()
            .onAppear {
                print("space pressed -> attempting to play preview")
                player = AVPlayer(url: URL(string: preview_url)!)
                player?.play()
                player?.volume = Float(volume)
            }
            .onDisappear {
                print("close preview")
                player?.pause()
                player = nil
            }
        } else {
            Text("No Preview found for this track")
        }
    }
}

#Preview("Preview View - With Preview URL") {
    PreviewView(track: PreviewData.track1)
}

#Preview("Preview View - Without Preview URL") {
    PreviewView(track: PreviewData.trackNoPreview)
}
