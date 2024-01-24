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
    let artists: [Artist]
    let album: Album
    let artwork: Artwork

    var body: some View {
        HStack {
            AsyncImage(url: artwork.url)
//                .resizable()
//                .scaledToFit()
            VStack(alignment: .leading) {
                Link(track.name, destination: URL(string: track.uri)!)
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
            Link(album.name, destination: URL(string: album.uri)!)
        }
        .foregroundStyle(.secondary)
    }
}

// TODO: Move some functionality here out to a class. view-model classs? or in the spotify API class?
struct CurrentTrackView: View {
    @State private var currentTrack: Track?
    @State private var isSaved: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        HStack {
            if let currentTrack {
                TrackView(track: currentTrack,
                          artists: currentTrack.artists,
                          album: currentTrack.album,
                          artwork: Artwork(url: URL(string: currentTrack.album.images.last!.url)!))
                Text(isSaved ? "♥︎" : "♡").padding(.all).font(.title)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                MySpotifyAPI.shared.GetCurrentTrack(accessToken: accessToken) { result in
                    if let firstResult = result.item {
                        DispatchQueue.main.async {
                            self.currentTrack = firstResult
                        }
                    }
                }
            }
        }
        .onChange(of: currentTrack) {
            MySpotifyAPI.shared.isSaved(ids: [currentTrack!.id], type: "track") { results in
                if let firstResult = results.first {
                    DispatchQueue.main.async {
                        self.isSaved = firstResult
                    }
                }
            }
        }
    }
}
