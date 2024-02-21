//
//  ArtistView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

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

//#Preview {
//    ArtistView()
//}
