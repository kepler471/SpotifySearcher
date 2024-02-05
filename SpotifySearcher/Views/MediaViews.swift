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

struct AlbumView: View {
    let artists: [Artist]
    let album: Album
    let artwork: Artwork
    
    var body: some View {
        HStack {
            AsyncImage(url: artwork.url)
            VStack(alignment: .leading) {
                Link(album.name, destination: URL(string: album.uri)!)
                    .font(.title)
                    .modifier(HoverUnderlineModifier())
                HStack {
                    ForEach(artists, id: \.id) { artist in
                        if artist.id != artists.last?.id {
                            Link(artist.name + ",", destination: URL(string: artist.uri)!)
                                .modifier(HoverUnderlineModifier())
                        } else {
                            Link(artist.name, destination: URL(string: artist.uri)!)
                                .modifier(HoverUnderlineModifier())
                        }
                    }
                }
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

struct ArtistView: View {
    let artist: Artist
    //    let artwork: Artwork
    
    var body: some View {
        HStack {
            //            AsyncImage(url: artwork.url)
            //                .resizable()
            //                .scaledToFit()
            Link(artist.name, destination: URL(string: artist.uri)!)
                .modifier(HoverUnderlineModifier())
            Spacer()
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

struct TrackView: View {
    let track: Track // TODO: Make these all Optionals
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: track.album.images.last!.url)!)
            VStack(alignment: .leading) {
                Link(track.name, destination: URL(string: track.uri)!)
                    .font(.title)
                    .modifier(HoverUnderlineModifier())
//                    .fixedSize(horizontal: true, vertical: false)
                HStack {
                    ForEach(track.artists, id: \.id) { artist in
                        if artist.id != track.artists.last?.id {
                            Link(artist.name + ",", destination: URL(string: artist.uri)!)
                                .modifier(HoverUnderlineModifier())
//                                .fixedSize(horizontal: true, vertical: false)
                        } else {
                            Link(artist.name, destination: URL(string: artist.uri)!)
                                .modifier(HoverUnderlineModifier())
//                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
            }
//            .frame(width: 300)
            Spacer()
            Link(track.album.name, destination: URL(string: track.album.uri)!)
                .modifier(HoverUnderlineModifier())
//                .fixedSize(horizontal: true, vertical: false)
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

struct CurrentTrackView: View {
    @EnvironmentObject var player: Player
    
    var body: some View {
        HStack {
            if let track = player.currentTrack {
                TrackView(track: track)
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

struct LikeButtonView: View {
    @EnvironmentObject var auth: Auth
    @EnvironmentObject var player: Player
    @State var isSaved: Bool = false
    
    var body: some View {
        
//        VStack {
//            Button(action: {}, label: {
//                Image(systemName: "leaf.fill")
//            })
//        }.accentColor(Color(.systemPink))
        
        Button {
            if isSaved {
                MySpotifyAPI.shared.removeTracksFromLibrary(accessToken: auth.accessToken, trackIds: [player.currentTrack!.id]) { error in
                    if let error {
                        print("<<<Like>>> 💔 Error trying to remove track from library: \(error)")
                    }
                }
            } else {
                MySpotifyAPI.shared.saveTracksToLibrary(accessToken: auth.accessToken, trackIds: [player.currentTrack!.id]) { error in
                    if let error {
                        print("<<<Like>>> ❤️ Error trying to save track to library: \(error)")
                    }
                }
            }
            isSaved.toggle()
        } label: {
            isSaved ? Image(systemName: "heart.fill") : Image(systemName: "heart")
        }
//        .foregroundStyle(.red)
//        .backgroundStyle(.blue)
//        .tint(.purple)
        .scaleEffect(1)
        .animation(.linear(duration: 1), value: 1)
        .onReceive(player.$currentTrack) { _ in
            MySpotifyAPI.shared.checkSaved(accessToken: auth.accessToken, type: "track", Ids: [player.currentTrack!.id]) { result, error  in
                if let error {
                    print("<<<Like>>> 🔎❤️ Error checking if track is saved in Library: \(error)")
                } else if let result {
                    isSaved = result.first!
                }
            }
        }
        .keyboardShortcut("s")
    }
}

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
