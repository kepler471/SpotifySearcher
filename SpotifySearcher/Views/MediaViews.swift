//
//  MediaViews.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 22/01/2024.
//

import Foundation
import SwiftUI
import AVFoundation

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
