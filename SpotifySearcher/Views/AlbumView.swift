//
//  AlbumView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

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

//#Preview {
//    AlbumView()
//}
