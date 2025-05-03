//
//  TrackView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

//Might need to set frame sizes for the sub views that make up track view. Might then be best to forget about
//                                    calculating the final app width, and just drop that external frame size.
//                                    This way we might be able to get marquee working.

struct TrackView: View {
    let track: Track // TODO: Make these all Optionals
    var isMarqueeActive = false
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: track.album.images.last!.url)!)
            VStack(alignment: .leading) {
                
                MarqueeView(track, linkType: .track, marquee: isMarqueeActive)
//                    .fixedSize(horizontal: true, vertical: false)
                
                MarqueeView(track, linkType: .artists, marquee: true)
//                    .fixedSize(horizontal: true, vertical: false)
                
            }
            .frame(width: 300, alignment: .leading)
            
            Spacer()
            
            MarqueeView(track, linkType: .album, marquee: isMarqueeActive)
//                .fixedSize(horizontal: true, vertical: false)
        }
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
        .listItemTint(.monochrome)
        .font(.title2)
    }
}

#Preview("Track with Short Names") {
    TrackView(track: PreviewData.track1)
}

#Preview("Track with Long Names") {
    TrackView(track: PreviewData.track3, isMarqueeActive: true)
}

#Preview("Track in List Context") {
    List {
        ForEach(PreviewData.tracks) { track in
            TrackView(track: track)
        }
    }
    .frame(width: 600, height: 300)
}
