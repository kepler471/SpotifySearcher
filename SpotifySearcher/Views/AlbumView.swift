//
//  AlbumView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

/// Displays a Spotify album with its artwork and associated artists
///
/// This view presents album information in a consistent format, including:
/// - Album artwork
/// - Album name (as a clickable link to open in Spotify)
/// - List of contributing artists (as clickable links)
///
/// The view is designed to work within list contexts and maintains consistent
/// styling with other media views in the application.
struct AlbumView: View {
    /// Artists who contributed to the album
    let artists: [Artist]
    
    /// The album to display
    let album: Album
    
    /// Artwork image for the album
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

#Preview("Album View") {
    AlbumView(
        artists: PreviewData.album1.artists,
        album: PreviewData.album1,
        artwork: PreviewData.artwork
    )
}

#Preview("Album with Multiple Artists") {
    AlbumView(
        artists: PreviewData.album2.artists,
        album: PreviewData.album2,
        artwork: PreviewData.artwork
    )
}
