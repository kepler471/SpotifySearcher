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
    let artists: [Artist]
    let artwork: Artwork

    var body: some View {
        HStack {
            AsyncImage(url: artwork.url)
//                .resizable()
//                .scaledToFit()
            HStack {
                ForEach(artists, id: \.id) { artist in
                    if artist.id != artists.last?.id {
                        Link(artist.name + ",", destination: URL(string: artist.uri)!)
                    } else {
                        Link(artist.name, destination: URL(string: artist.uri)!)
                    }
                }
                .font(.title)
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
    }
}

struct TrackView: View {
    let track: Track
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

struct CurrentTrackView: View {
    let track: Track
    let artists: [Artist]
    let album: Album
    let artwork: Artwork
    @State private var isSaved = false
    
    var body: some View {
        HStack {
            TrackView(track: track, artists: artists, album: album, artwork: artwork)
            Text(isSaved ? "♥︎" : "♡").padding(.all)
//            Spacer()
        }
        .onAppear {
            MySpotifyAPI.shared.isSaved(ids: [track.id], type: "track") { results in
                if let firstResult = results.first {
                    DispatchQueue.main.async {
                        self.isSaved = firstResult
                    }
                }
            }
        }
    }
}
