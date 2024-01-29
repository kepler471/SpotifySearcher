//
//  MediaViews.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 22/01/2024.
//

import Foundation
import SwiftUI

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
                HStack {
                    ForEach(artists, id: \.id) { artist in
                        if artist.id != artists.last?.id {
                            Link(artist.name + ",", destination: URL(string: artist.uri)!)
                        } else {
                            Link(artist.name, destination: URL(string: artist.uri)!)
                        }
                    }
                }
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
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
            Spacer()
        }
        .foregroundStyle(.secondary)
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
                HStack {
                    ForEach(track.artists, id: \.id) { artist in
                        if artist.id != track.artists.last?.id {
                            Link(artist.name + ",", destination: URL(string: artist.uri)!)
                        } else {
                            Link(artist.name, destination: URL(string: artist.uri)!)
                        }
                    }
                }
            }
            Spacer()
            Link(track.album.name, destination: URL(string: track.album.uri)!)
        }
        .foregroundStyle(.secondary)
    }
}

// TODO: Move some functionality here out to a class. view-model classs? or in the spotify API class?
struct CurrentTrackView: View {
    @Environment(Auth.self) private var auth
    @State private var currentTrack: Track?
    @State private var isSaved: Bool = false
    @State private var timer: Timer?
    @State private var isPlaying: Bool = false
    
    var body: some View {
        HStack {
            if let currentTrack {
                TrackView(track: currentTrack)
                
                Button {
                    print("click like")
                    if isSaved {
                        MySpotifyAPI.shared.removeTracksFromLibrary(accessToken: auth.accessToken, trackIds: [currentTrack.id]) { error in
                            if let error {
                                print("Error trying to remove track from library: \(error)")
                            } else {
                                print("Tracks successfully removed from the library")
                                isSaved = false
                            }
                        }
                    } else {
                        MySpotifyAPI.shared.saveTracksToLibrary(accessToken: auth.accessToken, trackIds: [currentTrack.id]) { error in
                            if let error {
                                print("Error trying to save track to library: \(error)")
                            } else {
                                print("Tracks successfully saved to the library")
                                isSaved = true
                            }
                        }
                    }

                } label: {
                    isSaved ? Image(systemName: "heart.fill") : Image(systemName: "heart")
                }
                .keyboardShortcut(KeyEquivalent("s"), modifiers: .command)

                Button {
                    print("click play/pause")
                    if isPlaying {
                        // TODO: Error wrap these 2 lines so we don't swap the button if the play/pause fails
                        MySpotifyAPI.shared.pausePlayback(accessToken: auth.accessToken)
                        isPlaying = false
                    } else {
                        // TODO: Error wrap these 2 lines so we don't swap the button if the play/pause fails
                        MySpotifyAPI.shared.startResumePlayback(accessToken: auth.accessToken)
                        isPlaying = true
                    }
                } label: {
                    isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                }

            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                MySpotifyAPI.shared.getCurrentTrack(accessToken: auth.accessToken) { result in
                    if let firstResult = result.item {
                        DispatchQueue.main.async {
                            self.currentTrack = firstResult
                            self.isPlaying = result.is_playing
                        }
                        
                        MySpotifyAPI.shared.checkTracksSavedInLibrary(accessToken: auth.accessToken, trackIds: [firstResult.id]) { savedStatus, error in
                            if let error {
                                print("Error checking if track is saved in Library: \(error)")
                            } else if let savedStatus {
                                isSaved = savedStatus.first!
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: currentTrack) {
            MySpotifyAPI.shared.isSaved(accessToken: auth.accessToken, ids: [currentTrack!.id], type: "track") { results in
                if let firstResult = results.first {
                    DispatchQueue.main.async {
                        self.isSaved = firstResult
                    }
                }
            }
        }
    }
}
