//
//  MarqueeView.swift
//  SpotifySearcher
//
//  Created by Stelios Georgiou on 05/02/2024.
//

import SwiftUI

let MAX_LINK_WIDTH = 300.0
let LEFT_PAD = 10.0

struct SizeCalculator: ViewModifier {
    
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

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

enum LinkType {
    case track
    case album
    case artists
}

//struct MarqueeView<Content: View>: View {
struct MarqueeView: View {
    @State var angle = 0.0
    @State var moveText = false
    @State var textSize: CGSize = .zero
    
    let track: Track
    let linkType: LinkType
    let marquee: Bool
    
    init(_ track: Track, linkType: LinkType, marquee: Bool) {
        self.track = track
        self.linkType = linkType
        self.marquee = marquee
    }
    
    var body: some View {
        
        let linkStack = HStack {
            switch linkType {
            case .track:
                Link(track.name, destination: URL(string: track.uri)!)
                    .font(.title)
                    .modifier(HoverUnderlineModifier())
                //                    .multilineTextAlignment(.leading)
                //                    .fixedSize(horizontal: true, vertical: false)
                //                    .truncationMode(.middle)
            case .album:
                Link(track.album.name, destination: URL(string: track.album.uri)!)
                    .modifier(HoverUnderlineModifier())
                //                    .fixedSize(horizontal: true, vertical: false)
            case .artists:
                ForEach(track.artists, id: \.id) { artist in
                    if artist.id != track.artists.last?.id {
                        Link(artist.name + ",", destination: URL(string: artist.uri)!)
                            .modifier(HoverUnderlineModifier())
                        //                            .fixedSize(horizontal: true, vertical: false)
                    } else {
                        Link(artist.name, destination: URL(string: artist.uri)!)
                            .modifier(HoverUnderlineModifier())
                        //                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
            }
        }
        
        if marquee {
            
            linkStack
            .offset(x: moveText ? -angle : angle, y: 0)
            // TODO: Adjust duration dependant on length of strings.
            .animation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: moveText)
            .fixedSize(horizontal: true, vertical: true)
            .gridColumnAlignment(linkType == .album ? .trailing : .leading)
            .saveSize(in: $textSize)
            .onAppear {
                if linkType == .album {
                    angle -= LEFT_PAD + (textSize.width - MAX_LINK_WIDTH) / 2
                } else {
                    angle += LEFT_PAD + (textSize.width - MAX_LINK_WIDTH) / 2
                }
                
                if textSize.width > MAX_LINK_WIDTH {
                    withAnimation {
                        self.moveText.toggle()
                    }
                } else {
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
            
            linkStack
            .gridColumnAlignment(linkType == .album ? .trailing : .leading)
            .saveSize(in: $textSize)
            .frame(width: MAX_LINK_WIDTH, height: 20, alignment: .leading)
            .lineLimit(1)
            .padding([.leading, .trailing])
        }
        
    }
}

#Preview {
    MarqueeView(blank1, linkType: .artists, marquee: true)
}
