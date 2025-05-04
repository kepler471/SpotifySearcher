//
//  TrackView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 20/02/2024.
//

import SwiftUI

/// Displays a Spotify track with its metadata
///
/// This view shows a track's essential information, including:
/// - Album artwork
/// - Track name (as a clickable link)
/// - Artist names (as clickable links)
/// - Album name (as a clickable link)
///
/// The view supports marquee scrolling for long text that doesn't fit within
/// the allocated space.
/// All text elements are links that open the corresponding resource in Spotify.
struct TrackView: View {
    /// The track to display
    let track: Track // TODO: Make these all Optionals
    
    /// Whether to enable marquee scrolling effect for track and album names
    ///
    /// Artist names always use marquee scrolling regardless of this setting.
    var isMarqueeActive = false
    
    var body: some View {
        HStack {
            // Album artwork
            AsyncImage(url: URL(string: track.album.images.last!.url)!)
            
            // Track and artist information
            VStack(alignment: .leading) {
                // Track name with optional marquee effect
                MarqueeView(track, linkType: .track, marquee: isMarqueeActive)
                
                // Artist names with forced marquee effect
                MarqueeView(track, linkType: .artists, marquee: true)
            }
            .frame(width: 300, alignment: .leading)
            
            Spacer()
            
            // Album name with optional marquee effect
            MarqueeView(track, linkType: .album, marquee: isMarqueeActive)
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
