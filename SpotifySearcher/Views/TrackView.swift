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

let blank0 = Track(name: "Rap Protester a", id: "6CCIqr8xROr3jTnXf4GI3B", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album ", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char ", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")


let blank1 = Track(name: "Rap Protester asldkfjhasldkfhas ldkfjhas lakjsdo", id: "6CCIqr8xROr3jTnXf4GI3B", album: Album(artists: [Artist(name: "Le Char", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "artist:URI")], name: "Fake Album Namea lkjsd alskhfda  qqqq qq qwe ksljfh", id: "1p12OAWwudgMqfMzjMvl2a", images: [SpotifyImage(url: "https://i.scdn.co/image/ab67616d00004851f38c6b37a21334e22005b1f7", height: 64, width: 64)], uri: "spotify:album:1p12OAWwudgMqfMzjMvl2a"), artists: [Artist(name: "Le Char asdf asdlkfjha sdkfjhas lkjfhasd lkfjhd sklfhd lkfjhf lkasdjf hlasdkjfh ", id: "09hVIj6vWgoCDtT03h8ZCa", uri: "spotify:artist:09hVIj6vWgoCDtT03h8ZCa")], uri: "spotify:track:6CCIqr8xROr3jTnXf4GI3B", preview_url: "https://p.scdn.co/mp3-preview/8ca060b3fa2f75ce0f1889f38fdc8562a763b801?cid=f050ee486c4f4ceeb53fd54ab2d3cedb")


#Preview {
    TrackView(track: blank1)
}
