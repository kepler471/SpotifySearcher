//
//  MarqueeView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 05/02/2024.
//

import SwiftUI

/// Maximum width for link text before triggering marquee scrolling effect
let MAX_LINK_WIDTH = 300.0

/// Left padding for text elements
let LEFT_PAD = 10.0

/// View modifier that calculates and stores the size of its content view
///
/// This utility modifier uses GeometryReader to measure its content's
/// dimensions and stores the result in a binding, allowing parent views
/// to adapt based on content size.
struct SizeCalculator: ViewModifier {
    
    /// Binding to store the calculated size
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

/// Adds a convenience method to save a view's size to a binding
extension View {
    /// Calculates and saves the view's size to the provided binding
    ///
    /// - Parameter size: Binding to store the calculated size
    /// - Returns: The modified view with size calculation capabilities
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

/// Types of Spotify content that can be displayed as links
enum LinkType {
    /// Track name
    case track
    
    /// Album name
    case album
    
    /// Artist names (can be multiple)
    case artists
}

/// Displays Spotify metadata with optional scrolling marquee effect
///
/// This specialized view displays track, album, or artist information as
/// clickable links that open in Spotify. For text that is too long to fit
/// in the allocated space, it supports a marquee scrolling effect that
/// animates the text back and forth to reveal the full content.
///
/// Each type of content (track, album, artists) is displayed with appropriate
/// formatting and alignment based on its position in the UI.
struct MarqueeView: View {
    /// Offset value for marquee animation
    @State var angle = 0.0
    
    /// Whether the text is currently moving in the marquee animation
    @State var moveText = false
    
    /// Calculated size of the text content
    @State var textSize: CGSize = .zero
    
    /// The track whose information is being displayed
    let track: Track
    
    /// What type of information to display (track, album, or artists)
    let linkType: LinkType
    
    /// Whether to enable the marquee scrolling effect
    let marquee: Bool
    
    /// Initializes a new MarqueeView
    ///
    /// - Parameters:
    ///   - track: The track whose information will be displayed
    ///   - linkType: What type of information to display
    ///   - marquee: Whether to enable the marquee scrolling effect
    init(_ track: Track, linkType: LinkType, marquee: Bool) {
        self.track = track
        self.linkType = linkType
        self.marquee = marquee
    }
    
    var body: some View {
        
        // Build the appropriate link stack based on content type
        let linkStack = HStack {
            switch linkType {
            case .track:
                Link(track.name, destination: URL(string: track.uri)!)
                    .font(.title)
                    .modifier(HoverUnderlineModifier())
            case .album:
                Link(track.album.name, destination: URL(string: track.album.uri)!)
                    .modifier(HoverUnderlineModifier())
            case .artists:
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
        
        // Apply marquee animation if enabled
        if marquee {
            
            linkStack
            .offset(x: moveText ? -angle : angle, y: 0)
            // TODO: Adjust duration dependant on length of strings.
            .animation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: moveText)
            .fixedSize(horizontal: true, vertical: true)
            .gridColumnAlignment(linkType == .album ? .trailing : .leading)
            .saveSize(in: $textSize)
            .onAppear {
                // Calculate initial position based on content width and type
                if linkType == .album {
                    angle -= LEFT_PAD + (textSize.width - MAX_LINK_WIDTH) / 2
                } else {
                    angle += LEFT_PAD + (textSize.width - MAX_LINK_WIDTH) / 2
                }
                
                // Only animate if content is wider than available space
                if marquee, textSize.width > MAX_LINK_WIDTH {
                    withAnimation {
                        self.moveText.toggle()
                    }
                } else {
                    // Adjust position for non-animated content
                    if linkType == .album {
                        angle += LEFT_PAD
                    } else {
                        angle -= LEFT_PAD
                    }
                }
            }
            .frame(width: MAX_LINK_WIDTH, height: 20, alignment: .center)
            .clipped(antialiased: true)
            .padding([.leading, .trailing])
            
        } else {
            // Standard non-animated view with ellipsis truncation
            linkStack
            .gridColumnAlignment(linkType == .album ? .trailing : .leading)
            .saveSize(in: $textSize)
            .frame(width: MAX_LINK_WIDTH, height: 20, alignment: .leading)
            .lineLimit(1)
            .padding([.leading, .trailing])
        }
        
    }
}

#Preview("Marquee with Artists") {
    MarqueeView(PreviewData.track3, linkType: .artists, marquee: true)
}

#Preview("Marquee with Track Name") {
    MarqueeView(PreviewData.track3, linkType: .track, marquee: true)
}

#Preview("Marquee with Album Name") {
    MarqueeView(PreviewData.track3, linkType: .album, marquee: true)
}

#Preview("Standard View (No Marquee)") {
    MarqueeView(PreviewData.track1, linkType: .track, marquee: false)
}
