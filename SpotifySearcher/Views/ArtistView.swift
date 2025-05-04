//
//  ArtistView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

/// Displays a Spotify artist as a clickable link
///
/// This view presents an artist's name as a clickable link that opens
/// in Spotify. The view is designed to be simple and consistent with
/// other media views in the application.
struct ArtistView: View {
    /// The artist to display
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

#Preview("Artist View") {
    ArtistView(artist: PreviewData.artist1)
}

#Preview("Artist with Long Name") {
    ArtistView(artist: PreviewData.artist2)
}
