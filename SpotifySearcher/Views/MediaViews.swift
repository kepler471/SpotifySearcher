//
//  MediaViews.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 22/01/2024.
//

import Foundation
import SwiftUI

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
//                .resizable()
//                .scaledToFit()
            VStack(alignment: .leading) {
                Link(track.name, destination: URL(string: track.uri)!)
                    .font(.title)
                    .modifier(HoverUnderlineModifier())
                HStack {
                    ForEach(track.artists, id: \.id) { artist in
                        if artist.id != track.artists.last?.id {
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
            Link(track.album.name, destination: URL(string: track.album.uri)!)
                .modifier(HoverUnderlineModifier())
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

/// Assuming a track is always playing (so we do not need to create a blank CurrentTrackView yet:
/// - how do we get it to update to whether the state is playing or paused?
/// - how do we get it to update to the currently playing track?
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
//    @State var track: Track
    
    var body: some View {
        
        Button {
            print("click like")
            
            if isSaved {
                MySpotifyAPI.shared.removeTracksFromLibrary(accessToken: auth.accessToken, trackIds: [player.currentTrack!.id]) { error in
                    if let error {
                        print("Error trying to remove track from library: \(error)")
                    } else {
                        print("Tracks successfully removed from the library")
                    }
                }
            } else {
                MySpotifyAPI.shared.saveTracksToLibrary(accessToken: auth.accessToken, trackIds: [player.currentTrack!.id]) { error in
                    if let error {
                        print("Error trying to save track to library: \(error)")
                    } else {
                        print("Tracks successfully saved to the library")
                    }
                }
            }
            isSaved.toggle()
        } label: {
            isSaved ? Image(systemName: "heart.fill") : Image(systemName: "heart")
        }
        .onReceive(player.$currentTrack) { _ in
            print("LikeBurron received \(player.$currentTrack)")
            MySpotifyAPI.shared.checkSaved(accessToken: auth.accessToken, type: "track", Ids: [player.currentTrack!.id]) { result, error  in
                print()
                if let error {
                    print("Error checking if track is saved in Library: \(error)")
                } else if let result {
                    isSaved = result.first!
                }
            }
        }
//        .onAppear {
//            print("LikeBurron received \(player.$currentTrack)")
//            MySpotifyAPI.shared.checkSaved(accessToken: auth.accessToken, type: "track", Ids: [player.currentTrack!.id]) { result, error  in
//                print()
//                if let error {
//                    print("Error checking if track is saved in Library: \(error)")
//                } else if let result {
//                    isSaved = result.first!
//                }
//            }
//        }
        .keyboardShortcut("s")
    }
}

struct PlayPauseButtonView: View {
    @EnvironmentObject var player: Player
    
    var body: some View {
        Button {
            /// The timer checks and updates `isPlaying`. If this button attempts to update `isPlaying`, there can be some crossover in the time it takes to pause/play, manually setting `isPlaying` in the Button, and the timer, causing the pause/play command to not do anything. For now lets just let the timer set isPlaying, but try to come up with a better way to manage this.
            print("click play/pause")
            player.togglePlaying()
        } label: {
            player.isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
        }
    }
}
